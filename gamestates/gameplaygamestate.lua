require 'view/character'
require 'view/enemy'
require 'view/pickup'

GameplayGameState = {}

local background = nil

local collisionCallbacks = {}

function GameplayGameState:init()
  self.character = Character()
  self.background = love.graphics.newImage( 'assets/images/background.jpg' )

  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight() * 0.1
  local cx = -(sw * 0.95)
  self.stats = {
    color = {0, 0, 0, 255 * 0.66},
    openX = 0,
    closeX = cx,
    x = 0,
    y = love.graphics.getHeight() - sh,
    width = sw,
    height = sh,
    open = true
  }
end

function createPickup()
  local r = 10
  local x = math.random( r, love.graphics.getWidth() - r )
  local y = math.random( r, love.graphics.getHeight() - r )
  local types = {Pickup.Type.Money, Pickup.Type.Food, Pickup.Type.Water, Pickup.Type.Drink}
  local rand = math.randomInt( 1, #types )
  local t = types[rand]
  local v = math.randomRange( 1, 50 )

  return Pickup( x, y, r, r, t, v )
end

function GameplayGameState:enter()
  self.character:setState( Character.State.Standing )

  self.character.x = love.graphics.getWidth() * 0.5 - self.character:getWidth() * 0.5
  self.character.y = love.graphics.getHeight() * 0.5 - self.character:getHeight() * 0.5

  local m, f, w, d = math.randomInt( 75, 150 ), math.randomInt( 75, 150 ), math.randomInt( 75, 150 ), math.randomInt( 75, 150 )
  local md, fd, wd, dd = math.random( 0.05, 0.2 ), math.random( 0.05, 0.2 ), math.random( 0.05, 0.2 ), math.random( 0.05, 0.2 )
  self.values = {
    --  val, orig, decay
    {m, m, md}, --  Money
    {f, f, fd}, --  Food
    {w, w, wd}, --  Water
    {d, d, dd} --  Drink
  }

  local function generateDecayFunc( gs )
    return function()
      for _, v in ipairs( gs.values ) do
        v[1] = v[1] - (v[2] * v[3])
        v[3] = math.random( 0.05, 0.2 )
      end
    end
  end

  self.decayTimer = Timer.addPeriodic( 1, generateDecayFunc( self ) )

  self.hitsToDraw = {}

  self.pickups = {}
  for i = 1, 20 do
    self.pickups[ #self.pickups + 1 ] = createPickup()
  end

  self.enemies = {}
  for i = 1, 10 do
    local lx = math.random()
    self.enemies[ #self.enemies + 1 ] = Enemy( lx > 0.5 and love.graphics.getWidth() + 80 or -80, math.random( 0, love.graphics.getHeight() - 75 ) )
    self.enemies[ #self.enemies ]:setState( Enemy.State.Walking )
  end

  Collider:setCallbacks( on_collision, collision_stop )
end

function GameplayGameState:findPickupIndex( pickup )
  for i, v in ipairs( self.pickups ) do
    if self.pickups[i] == pickup then
      return i
    end
  end
  return nil
end

function GameplayGameState:applyPickupValueForAppropriateType( pickup )
  assert( pickup, 'applyPickupValueForAppropriateType: pickup passed ' .. tostring( pickup ) .. ' cannot be nil' )

  local types = {Pickup.Type.Money, Pickup.Type.Food, Pickup.Type.Water, Pickup.Type.Drink}
  local idx = 1
  for i, v in ipairs( types ) do
    if v.label == pickup.ptype.label then
      idx = i
      break
    end
  end

  self.values[idx][1] = self.values[idx][1] + pickup.value
end

function CharacterPickupCollision( dt, char, pickup, dx, dy )
  local idx = Gamestate.current():findPickupIndex( pickup )
  if idx then
    Gamestate.current():applyPickupValueForAppropriateType( pickup )
    Gamestate.current().pickups[ idx ] = createPickup()
  end
end

function CharacterEnemyCollision( dt, char, enemy, dx, dy )
  if char:getState() == Character.State.Death or enemy:getState() == Enemy.State.Death then
    return
  end

  if char:getState() == Character.State.Attacking then
    enemy:setState( Enemy.State.Death )
  elseif enemy:getState() == Enemy.State.Attacking then
    for _, v in ipairs( Gamestate.current().values ) do
      v[1] = v[1] - (v[2] * v[3])
      char:setState( Character.State.Damage )
    end
  elseif not char:isInvincible() then
    enemy:setState( Enemy.State.Attacking )
    local ew, eh = enemy:getWidth() * 0.5, enemy:getHeight() * 0.5
    enemy.target = {math.random( ew, love.graphics.getWidth() - ew ), math.random( eh, love.graphics.getHeight() - eh)}
  end
end

function EnemyEnemyCollision( dt, e1, e2, dx, dy )
  if e1:getState() == Enemy.State.Attacking then
    if e2:getState() == Enemy.State.Attacking then
      e2:setState( Enemy.State.Damage )
    else
      e2.x = e2.x - dx * dt
      e2.y = e2.y - dy * dt
    end
  elseif e2:getState() == Enemy.State.Attacking then
    if e1:getState() == Enemy.State.Attacking then
      e1:setState( Enemey.State.Damage )
    else
      e1.x = e1.x + dx * dt
      e1.y = e1.y + dy * dt
    end
  else
    e1.x = e1.x + dx * dt
    e1.y = e1.y + dy * dt
  end
end

function on_collision( dt, shapeA, shapeB, dx, dy )
  if shapeA.source:is( Character ) then
    if shapeB.source:is( Pickup ) then
      CharacterPickupCollision( dt, shapeA.source, shapeB.source, dx, dy )
    elseif shapeB.source:is( Enemy ) then
      CharacterEnemyCollision( dt, shapeA.source, shapeB.source, dx, dy )
    end
  elseif shapeB.source:is( Character ) then
    if shapeA.source:is( Pickup ) then
      CharacterPickupCollision( dt, shapeB.source, shapeA.source, dx, dy )
    elseif shapeA.source:is( Enemy ) then
      CharacterEnemyCollision( dt, shapeB.source, shapeA.source, dx, dy )
    end
  elseif shapeA.source:is( Enemy ) and shapeB.source:is( Enemy ) then
    EnemyEnemyCollision( dt, shapeA.source, shapeB.source, dx, dy )
  end
end

function collision_stop( dt, shapeA, shapeB )

end

function GameplayGameState:update( dt )
  for _, v in ipairs( self.values ) do
    if v[1] <= -1000 then
      self.character:setState( Character.State.Death )
    end
  end

  self.character:update( dt )
  
  for i, v in ipairs( self.enemies ) do
    if v.dead then
      local lx = math.random()
      self.enemies[i] = Enemy( lx > 0.5 and love.graphics.getWidth() + 80 or -80, math.random( 0, love.graphics.getHeight() - 75 ) )
      self.enemies[i]:setState( Enemy.State.Walking )
    else
      v:update( dt, self.character )
    end
  end
end

function GameplayGameState:draw()
  love.graphics.draw( self.background, 0, 0 )
  self.character:draw()

  for i, v in ipairs( self.pickups ) do
    v:draw()
  end

  for i, v in ipairs( self.enemies ) do
    v:draw()
  end

  love.graphics.push()
  love.graphics.setColor( 255, 255, 0 )
  for i = #self.hitsToDraw, 1, -1 do
    self.hitsToDraw[i].count = self.hitsToDraw[i].count + 1
    love.graphics.rectangle( 'line', self.hitsToDraw[i].x, self.hitsToDraw[i].y, self.hitsToDraw[i].width, self.hitsToDraw[i].height )
    love.graphics.circle( 'line', self.hitsToDraw[i].circ[1][1], self.hitsToDraw[i].circ[1][2], self.hitsToDraw[i].circ[2] )
  end
  love.graphics.pop()

  --  Stats panel
  love.graphics.push()
    love.graphics.translate( self.stats.x, self.stats.y )

    love.graphics.setColor( self.stats.color )
    love.graphics.rectangle( 'fill', 0, 0, self.stats.width, self.stats.height )

    love.graphics.setColor( 255, 255, 255, 255 )
    local w = (love.graphics.getWidth() - 40) * 0.25
    love.graphics.printf( string.format( 'Your money: $%.02f', self.values[1][1] ), 20, 20, self.stats.width - 40, 'left' )
    love.graphics.printf( string.format( 'Your food: %.02f', self.values[2][1] ), 20 + w, 20, self.stats.width - 40, 'left' )
    love.graphics.printf( string.format( 'Your water: %.02f', self.values[3][1] ), 20 + w * 2, 20, self.stats.width - 40, 'left' )
    love.graphics.printf( string.format( 'Your drink: %.02f', self.values[4][1] ), 20 + w * 3, 20, self.stats.width - 40, 'left' )
  love.graphics.pop()
end

function GameplayGameState:focus( focus )
end

function GameplayGameState:keypressed( key, isrepeat )
  self.character:keypressed( key, isrepeat )

  if key == 'kpenter' or key == 'return' then
    Gamestate.switch( State.End )
  end
end

function GameplayGameState:keyreleased( key )
  self.character:keyreleased( key )

  --[[
  if key == 'tab' then
    self.stats.open = not self.stats.open
    local tx = self.stats.open and self.stats.openX or self.stats.closeX
    local tt = self.stats.open and 'in' or 'out'
    Timer.tween( 0.15, self.stats, {x = tx}, tt..'-back' )
  end
  ]]
end

function GameplayGameState:mousepressed( x, y, button )
end

function GameplayGameState:mousereleased( x, y, button )
end

function GameplayGameState:leave()
  Collider:clear()
end

return GameplayGameState