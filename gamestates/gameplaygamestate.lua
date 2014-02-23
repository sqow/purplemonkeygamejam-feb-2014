require 'view/character'
require 'view/pickup'

GameplayGameState = {}

local background = nil
local Collider

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

  self.investments = {
    ['Shitty Job'] = 25,
    ['Student Loans'] = -1000
  }
end

function GameplayGameState:enter()
  Collider = HC(100, on_collision, collision_stop)
end

function inRange( value, min, max )
  return value >= math.min( min, max ) and value <= math.max( max, min )
end

function pointInRectangle( point, rect )
  assert( type( point ) == 'table', 'pointInRectangle: The point passed should be a table in the format {x, y} where x and y are numbers' )
  assert( #point == 2, 'pointInRectangle: The point passed does not have the appropriate length of 2.' )
  assert( type( point[1] ) == 'number' and type( point[2] ) == 'number', 'pointInRectangle: The point passed\'s values should both be numbers' )

  assert( type( rect ) == 'table', 'pointInRectangle: The rect passed should be a table in the format {x1, y1, x2, y2} where x1, x2, y1, and y2 are numbers' )
  assert( #rect == 4, 'pointInRectangle: The rect passed does not have the appropriate length of 4.' )
  assert( type( rect[1] ) == 'number' and
          type( rect[2] ) == 'number' and
          type( rect[3] ) == 'number' and
          type( rect[4] ) == 'number', 'pointInRectangle: The rect passed\'s values should all be numbers' )

  local px, py = unpack( point )
  local rx1, ry1, rx2, ry2 = unpack( rect )

  if inRange( px, rx1, rx1 + (rx2 - rx1) ) and inRange( py, ry1, ry1 + (ry2 - ry1) ) then
    print( 'point (' .. tostring( px ) .. ', ' .. tostring( py ) .. ') in rectangle (' .. tostring( rx1 ) .. ', ' .. tostring( ry1 ) .. ', ' .. tostring( rx2 ) .. ', ' .. tostring( ry2 ) .. ')' )
  end
  return inRange( px, rx1, rx1 + (rx2 - rx1) ) and inRange( py, ry1, ry1 + (ry2 - ry1) )
end

--  FIXME
function intersectCircle( circ, point )
  assert( type( circ ) == 'table', 'intersectCircle: The circ passed should be a table in the format {point, radius} where point is a table of two numbers and radius is a number' )
  assert( #circ == 2, 'intersectCircle: The circ passed does not have the appropriate length of 2.' )
  assert( type( circ[1] ) == 'table' and type( circ[2] ) == 'number', 'intersectCircle: The circ passed\'s values should be a table and a number' )

  assert( type( circ[1] ) == 'table', 'intersectCircle: The point in the circle passed should be a table in the format {x, y} where x and y are numbers' )
  assert( #circ[1] == 2, 'intersectCircle: The point in the circle passed does not have the appropriate length of 2.' )
  assert( type( circ[1][1] ) == 'number' and type( circ[1][2] ) == 'number', 'intersectCircle: The point in the circle passed\'s values should both be numbers' )

  assert( type( point ) == 'table', 'intersectCircle: The point passed should be a table in the format {x, y} where x and y are numbers' )
  assert( #point == 2, 'intersectCircle: The point passed does not have the appropriate length of 2.' )
  assert( type( point[1] ) == 'number' and type( point[2] ) == 'number', 'intersectCircle: The point passed\'s values should both be numbers' )

  local dx, dy = circ[1][1] - point[1], circ[1][2] - point[2]
  if dx * dx + dy * dy < circ[2] * circ[2] then
    print( '(' .. tostring( circ[1][1] ) .. ', ' .. tostring( circ[1][2] ) .. ') radius ' .. tostring( circ[2] ) .. ' against (' .. tostring( point[1] ) .. ', ' .. tostring( point[2] ) .. ')' )
  end
  return dx * dx + dy * dy < circ[2] * circ[2]
end

function circleRectCollision( circ, rect )
  assert( type( circ ) == 'table', 'circleRectCollision: The circ passed should be a table in the format {point, radius} where point is a table of two numbers and radius is a number' )
  assert( #circ == 2, 'circleRectCollision: The circ passed does not have the appropriate length of 2.' )
  assert( type( circ[1] ) == 'table' and type( circ[2] ) == 'number', 'circleRectCollision: The circ passed\'s values should be a table and a number' )

  assert( type( circ[1] ) == 'table', 'circleRectCollision: The point in the circle passed should be a table in the format {x, y} where x and y are numbers' )
  assert( #circ[1] == 2, 'circleRectCollision: The point in the circle passed does not have the appropriate length of 2.' )
  assert( type( circ[1][1] ) == 'number' and type( circ[1][2] ) == 'number', 'circleRectCollision: The point in the circle passed\'s values should both be numbers' )

  assert( type( rect ) == 'table', 'circleRectCollision: The rect passed should be a table in the format {x1, y1, x2, y2} where x1, x2, y1, and y2 are numbers' )
  assert( #rect == 4, 'circleRectCollision: The rect passed does not have the appropriate length of 4.' )
  assert( type( rect[1] ) == 'number' and
          type( rect[2] ) == 'number' and
          type( rect[3] ) == 'number' and
          type( rect[4] ) == 'number', 'circleRectCollision: The rect passed\'s values should all be numbers' )

  return pointInRectangle( circ[1], rect ) or
         intersectCircle( circ, {rect[1], rect[2]} ) or
         intersectCircle( circ, {rect[2], rect[3]} ) or
         intersectCircle( circ, {rect[3], rect[4]} ) or
         intersectCircle( circ, {rect[4], rect[1]} )
end

function GameplayGameState:update( dt )
  self.character:update( dt )

  local cx, cy, cw, ch = self.character.x, self.character.y, self.character:getWidth(), self.character:getHeight()
  local fw, fh = self.character:getState().spriteWidth, self.character:getState().spriteHeight
  local cntrx, cntry = cx + fw * 0.5, cy + fh * 0.5

  for i, v in ipairs( self.pickups ) do
    self.pickups[i]:update( dt )

    local cr = math.max( self.pickups[i].width, self.pickups[i].height )
    local cp = {self.pickups[i].x, self.pickups[i].y}
    local circ = {cp, cr}
    local rect = {cntrx - cw * 0.5, cntry - ch * 0.5, cntrx + cw * 0.5, cntry + ch * 0.5}

    if circleRectCollision( circ, rect ) then
      self.pickups[i] = Pickup( math.random( 10, love.graphics.getWidth() - 10 ), math.random( 10, love.graphics.getHeight() - 10 ), 10, 10, nil, nil, key, math.ceil( math.random( 0, 100 ) ) )
      self.hitsToDraw[ #self.hitsToDraw + 1 ] = {
        x = rect[1],
        y = rect[2],
        width = rect[3] - rect[1],
        height = rect[4] - rect[2],
        circ = circ,
        count = 0
      }
    end
  end
end

function GameplayGameState:draw()
  love.graphics.draw( self.background, 0, 0 )
  self.character:draw()

  for i, v in ipairs( self.pickups ) do
    self.pickups[i]:draw()
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
end

return GameplayGameState