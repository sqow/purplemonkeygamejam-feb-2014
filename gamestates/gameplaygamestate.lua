require 'view/character'
require 'view/pickup'

GameplayGameState = {}

local background = nil

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
end

function GameplayGameState:update( dt )
  self.character:update( dt )

  local cx, cy, cw, ch = self.character.x, self.character.y, self.character:getState().spriteWidth, self.character:getState().spriteHeight

  for i, v in ipairs( self.pickups ) do
    self.pickups[i]:update( dt )

    local dx = (cx + cw * 0.5) - (self.pickups[i].x + self.pickups[i].width * 0.5)
    local dy = (cy + ch * 0.5) - (self.pickups[i].y + self.pickups[i].height * 0.5)
    local dist = math.sqrt( dx * dx + dy * dy )
    if dist < math.max( (cw + self.pickups[i].width) * 0.5, (ch + self.pickups[i].height) * 0.5 ) then
      self.pickups[i] = Pickup( math.random( 10, love.graphics.getWidth() - 10 ), math.random( 10, love.graphics.getHeight() - 10 ), 10, 10, nil, nil, key, math.ceil( math.random( 0, 100 ) ) )
    end
  end
end

function GameplayGameState:draw()
  love.graphics.draw( self.background, 0, 0 )
  self.character:draw()

  for i, v in ipairs( self.pickups ) do
    self.pickups[i]:draw()
  end

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