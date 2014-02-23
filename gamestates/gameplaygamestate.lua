require 'view/character'
require 'view/enemy'
require 'view/pickup'

GameplayGameState = {}

local background = nil

local collisionCallbacks = {}

function GameplayGameState:init()
  self.character = Character()
  self.background = love.graphics.newImage( 'assets/images/background.jpg' )

  local sw, sh = love.graphics.getWidth() * 0.34, love.graphics.getHeight() * 0.5
  local cx = -(sw * 0.95)
  self.stats = {
    color = {0, 0, 0, 255 * 0.66},
    openX = 0,
    closeX = cx,
    x = cx,
    y = 0,
    width = sw,
    height = sh,
    open = false
  }

  self.money = 100

  self.hitsToDraw = {}

  self.pickups = {}
  for i = 1, 20 do
    local key = math.random() > 0.5 and 'Shitty Job' or 'Student Loans'
    self.pickups[ #self.pickups + 1 ] = Pickup( math.random( 10, love.graphics.getWidth() - 10 ), math.random( 10, love.graphics.getHeight() - 10 ), 10, 10, nil, nil, key, math.ceil( math.random( 0, 100 ) ) )
  end

  self.enemies = {}
  for i = 1, 10 do
    local lx = math.random()
    self.enemies[ #self.enemies + 1 ] = Enemy( lx > 0.5 and love.graphics.getWidth() + 80 or -80, math.random( 0, love.graphics.getHeight() - 75 ) )
    self.enemies[ #self.enemies ]:setState( Enemy.State.Walking )
  end

  self.investments = {
    ['Shitty Job'] = 25,
    ['Student Loans'] = -1000
  }
end

function GameplayGameState:enter()
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

function on_collision( dt, shapeA, shapeB, mtvX, mtvY )
  local idx
  if shapeA.source:is( Character ) then
    if shapeB.source:is( Pickup ) then
      idx = Gamestate.current():findPickupIndex( shapeB.source )
      if idx then
        Gamestate.current().pickups[ idx ] = Pickup( math.random( 10, love.graphics.getWidth() - 10 ), math.random( 10, love.graphics.getHeight() - 10 ), 10, 10, nil, nil, key, math.ceil( math.random( 0, 100 ) ) )
      end
    elseif shapeB.source:is( Enemy ) then
      if shapeB.source:getState() == Enemy.State.Attacking then
        --  TODO
      else
        shapeB.source:setState( Enemy.State.Attacking )
      end
    end
  elseif shapeB.source:is( Character ) then
    if shapeA.source:is( Pickup ) then
      idx = Gamestate.current():findPickupIndex( shapeA.source )
      if idx then
        Gamestate.current().pickups[ idx ] = Pickup( math.random( 10, love.graphics.getWidth() - 10 ), math.random( 10, love.graphics.getHeight() - 10 ), 10, 10, nil, nil, key, math.ceil( math.random( 0, 100 ) ) )
      end
    elseif shapeA.source:is( Enemy ) then
      if shapeA.source:getState() == Enemy.State.Attacking then
        --  TODO
      else
        shapeA.source:setState( Enemy.State.Attacking )
      end
    end
  elseif shapeA.source:is( Enemy ) and shapeB.source:is( Enemy ) then
    if shapeA.source:getState() == Enemy.State.Attacking then
      if shapeB.source:getState() == Enemy.State.Attacking then
        shapeB.source:setState( Enemy.State.Damage )
      else
        shapeB.source.x = shapeB.source.x - mtvX
        shapeB.source.y = shapeB.source.y - mtvY
      end
    elseif shapeB.source:getState() == Enemy.State.Attacking then
      if shapeA.source:getState() == Enemy.State.Attacking then
        shapeA.source:setState( Enemey.State.Damage )
      else
        shapeA.source.x = shapeA.source.x + mtvX
        shapeA.source.y = shapeA.source.y + mtvY
      end
    else
      shapeA.source.x = shapeA.source.x + mtvX
      shapeA.source.y = shapeA.source.y + mtvY
    end
  end
end

function collision_stop( dt, shapeA, shapeB )

end

function GameplayGameState:update( dt )
  self.character:update( dt )
  
  for i, v in ipairs( self.enemies ) do
    v:update( dt, self.character )
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
    love.graphics.printf( string.format( 'Your money: $%.02f', self.money ), 20, 20, self.stats.width - 40, 'left' )
    love.graphics.printf( string.rep( '-', 45 ), 20, 30, self.stats.width - 40, 'left' )
    love.graphics.printf( 'Your investments:', 20, 50, self.stats.width - 40, 'left' )
    local i = 65
    for k, v in pairs( self.investments ) do
      love.graphics.printf( tonumber( v ) >= 0 and '+' or '-', 20, i, self.stats.width - 40, 'left' )
      love.graphics.printf( tostring( k ) .. ':', 40, i, self.stats.width - 40, 'left' )
      love.graphics.printf( string.format( '$%.02f', tonumber( v ) ), 20, i, self.stats.width - 40, 'right' )
      i = i + 15
    end
  love.graphics.pop()
end

function GameplayGameState:focus( focus )
end

function GameplayGameState:keypressed( key, isrepeat )
  self.character:keypressed( key, isrepeat )
end

function GameplayGameState:keyreleased( key )
  self.character:keyreleased( key )

  if key == 'tab' then
    self.stats.open = not self.stats.open
    local tx = self.stats.open and self.stats.openX or self.stats.closeX
    local tt = self.stats.open and 'in' or 'out'
    Timer.tween( 0.15, self.stats, {x = tx}, tt..'-back' )
  end
end

function GameplayGameState:mousepressed( x, y, button )
end

function GameplayGameState:mousereleased( x, y, button )
end

function GameplayGameState:leave()
  Collider:clear()
end

return GameplayGameState