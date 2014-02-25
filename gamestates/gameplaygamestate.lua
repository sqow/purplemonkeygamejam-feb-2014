require 'view/character'
require 'view/enemy'
require 'view/pickup'

GameplayGameState = {}

local background = nil

local collisionCallbacks = {}

local BigFont
local RegFont

function GameplayGameState:init()
  self.character = Character()
  self.background = love.graphics.newImage( 'assets/images/background.jpg' )

  BigFont = love.graphics.newFont( 36 )
  RegFont = love.graphics.getFont()

  local sw, sh = love.graphics.getWidth(), 54
  local cx = -(sw * 0.95)
  self.stats = {
    color = {255, 255, 255, 255 * 0.66},
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
  local types = {Pickup.Type.Money, Pickup.Type.Food, Pickup.Type.Water}--, Pickup.Type.Drink}
  local rand = math.randomInt( 1, #types )
  local t = types[rand]
  local v = math.randomRange( 1, 50 )

  return Pickup( x, y, r, r, t, v )
end

function GameplayGameState:enter()
  self.character:setState( Character.State.Standing )

  self.character.x = love.graphics.getWidth() * 0.5 - self.character:getWidth() * 0.5
  self.character.y = love.graphics.getHeight() * 0.5 - self.character:getHeight() * 0.5

  local m, f, w--[[, d]] = math.randomInt( 75, 150 ), math.randomInt( 75, 150 ), math.randomInt( 75, 150 )--, math.randomInt( 75, 150 )
  local md, fd, wd--[[, dd]] = math.random( 0.05, 0.2 ), math.random( 0.05, 0.2 ), math.random( 0.05, 0.2 )--, math.random( 0.05, 0.2 )
  self.values = {
    --  val, orig, decay
    {m, m, md}, --  Money
    {f, f, fd}, --  Food
    {w, w, wd}--[[, --  Water
    {d, d, dd} --  Drink]]
  }

  self.bgMusic = love.audio.newSource( 'assets/sounds/bg.mp3', 'stream' )
  self.bgMusic:setLooping( true )
  self.bgMusic:play()

  self.sounds = {
    timer = love.audio.newSource( 'assets/sounds/Timer.wav', 'static' ),
    hit = love.audio.newSource( 'assets/sounds/Hit.wav', 'static' ),
    pickup = love.audio.newSource( 'assets/sounds/Pickup.wav', 'static' ),
    death = love.audio.newSource( 'assets/sounds/Death.wav', 'static' )
  }

  self.doBigScreenShake = false
  self.doSmallScreenShake = false

  self.sounds.timer:setVolume( 0.25 )
  self.sounds.pickup:setVolume( 0.5 )

  local function generateDecayFunc( gs )
    return function()
      if gs.character:getState() == Character.State.Death then
        return
      end
      gs.sounds.timer:play()
      for _, v in ipairs( gs.values ) do
        v[1] = v[1] - (v[2] * v[3])
        v[3] = math.random( 0.05, 0.2 )
      end
    end
  end

  local function generateTimerFunc( gs )
    return function()
      gs.countTime = gs.countTime + 1
    end
  end

  self.countTime = 0
  self.decayTimer = Timer.addPeriodic( 1, generateDecayFunc( self ) )
  self.countTimer = Timer.addPeriodic( 1, generateTimerFunc( self ) )

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
    Gamestate.current().sounds.pickup:play()
    Gamestate.current():applyPickupValueForAppropriateType( pickup )
    Gamestate.current().pickups[ idx ] = createPickup()
  end
end

function CharacterEnemyCollision( dt, char, enemy, dx, dy )
  local cs, es = char:getState(), enemy:getState()
  local ex, ey = enemy.hitShape:center()
  local cx, cy = char.hitShape:center()
  if cs == Character.State.Death or es == Enemy.State.Death then
    return
  end

  if cs == Character.State.Attacking then
    if math.abs( ey - cy ) < char:getHeight() * 0.34 then
      for _, v in ipairs( Gamestate.current().values ) do
        v[1] = v[1] + (v[2] * 0.34)
      end
      enemy:setState( Enemy.State.Death )
      Gamestate.current().sounds.hit:play()
      Gamestate.current().doSmallScreenShake = true
      Timer.add( 0.4, function() Gamestate.current().doSmallScreenShake = false end )
    end
  elseif es == Enemy.State.Attacking and cs ~= Character.State.Damage and not char:isInvincible() then
    if math.abs( ey - cy ) < char:getHeight() * 0.34 then
      for _, v in ipairs( Gamestate.current().values ) do
        v[1] = v[1] - (v[2] * v[3])
      end
      Gamestate.current().sounds.hit:play()
      char:setState( Character.State.Damage )
      Gamestate.current().doBigScreenShake = true
      Timer.add( 0.2, function() Gamestate.current().doBigScreenShake = false end )
    end
  elseif not char:isInvincible() then
    if math.abs( ey - cy ) < char:getHeight() * 0.34 then
      enemy:setState( Enemy.State.Attacking )
      local ew, eh = enemy:getWidth() * 0.5, enemy:getHeight() * 0.5
      enemy.target = {math.random( ew, love.graphics.getWidth() - ew ), math.random( eh, love.graphics.getHeight() - eh)}
    end
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
    if v[1] <= -1000 and self.character:getState() ~= Character.State.Death then
      self.sounds.death:play()
      self.character:setState( Character.State.Death )
      Gamestate.current().doBigScreenShake = true
      Timer.add( 0.6, function() Gamestate.current().doBigScreenShake = false end )
      Collider:clear()
      Timer.cancel( self.decayTimer )
      Timer.cancel( self.countTimer )
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
  if self.doBigScreenShake then
    love.graphics.push()
    local shakeAmt = math.random( -10, 10 )
    love.graphics.translate( shakeAmt, shakeAmt )
  elseif self.doSmallScreenShake then
    love.graphics.push()
    local shakeAmt = math.random( -5, 5 )
    love.graphics.translate( shakeAmt, shakeAmt )
  end

  love.graphics.setColor( 255, 255, 255, 255 )
  love.graphics.draw( self.background, 0, 0 )
  self.character:draw()

  for i, v in ipairs( self.pickups ) do
    v:draw()
  end

  for i, v in ipairs( self.enemies ) do
    v:draw()
  end

  love.graphics.push()
    local seconds = self.countTime % 60
    local minutes = math.floor( self.countTime / 60 ) % 60
    local hours = math.floor( self.countTime / 60 / 60 )
    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.setFont( BigFont )
    love.graphics.printf( string.format( '%02d:%02d:%02d', hours, minutes, seconds ), 0, 0, love.graphics.getWidth(), 'center' )
    love.graphics.setFont( RegFont )
  love.graphics.pop()

  --  Stats panel
  love.graphics.push()
    love.graphics.translate( self.stats.x, self.stats.y )

    love.graphics.setColor( self.stats.color )
    love.graphics.rectangle( 'fill', 0, 0, self.stats.width, self.stats.height )

    local w = (love.graphics.getWidth() - 40) * 0.33
    local mw = math.clamp( math.map( self.values[1][1], -1000, 1000, 0, w - 10), 0, w - 10 )
    local fw = math.clamp( math.map( self.values[2][1], -1000, 1000, 0, w - 10), 0, w - 10 )
    local ww = math.clamp( math.map( self.values[3][1], -1000, 1000, 0, w - 10), 0, w - 10 )
    local icolor = {math.abs(255 - self.stats.color[1]), math.abs(255 - self.stats.color[2]), math.abs(255 - self.stats.color[3]), 255}

    love.graphics.push()
      love.graphics.translate( 20, 15 )
      love.graphics.setColor( Pickup.Type.Money.color )
      love.graphics.rectangle( 'fill', 5, 5, mw, 15 )

      love.graphics.setColor( 0, 0, 0, 255 )
      love.graphics.rectangle( 'line', 0, 0, w, 25 )

      love.graphics.setColor( unpack( icolor ) )
      love.graphics.printf( string.format( 'Your money: $%.02f', self.values[1][1] ), 0, 5, w, 'center' )
    love.graphics.pop()

    love.graphics.push()
      love.graphics.translate( 20 + w, 15 )
      love.graphics.setColor( Pickup.Type.Food.color )
      love.graphics.rectangle( 'fill', 5, 5, fw, 15 )

      love.graphics.setColor( 0, 0, 0, 255 )
      love.graphics.rectangle( 'line', 0, 0, w, 25 )

      love.graphics.setColor( unpack( icolor ) )
      love.graphics.printf( string.format( 'Your food: %.02f',   self.values[2][1] ), 0, 5, w, 'center' )
    love.graphics.pop()

    love.graphics.push()
      love.graphics.translate( 20 + w * 2, 15 )
      love.graphics.setColor( Pickup.Type.Water.color )
      love.graphics.rectangle( 'fill', 5, 5, ww, 15 )

      love.graphics.setColor( 0, 0, 0, 255 )
      love.graphics.rectangle( 'line', 0, 0, w, 25 )

      love.graphics.setColor( unpack( icolor ) )
      love.graphics.printf( string.format( 'Your water: %.02f',  self.values[3][1] ), 0, 5, w, 'center' )
    love.graphics.pop()
  love.graphics.pop()

  if self.doBigScreenShake or self.doSmallScreenShake then
    love.graphics.pop()
  end
end

function GameplayGameState:focus( focus )
end

function GameplayGameState:keypressed( key, isrepeat )
  self.character:keypressed( key, isrepeat )
end

function GameplayGameState:keyreleased( key )
  self.character:keyreleased( key )
end

function GameplayGameState:mousepressed( x, y, button )
end

function GameplayGameState:mousereleased( x, y, button )
end

function GameplayGameState:leave()
  Collider:clear()
  Timer.cancel( self.decayTimer )
  Timer.cancel( self.countTimer )
  self.bgMusic:stop()
end

return GameplayGameState