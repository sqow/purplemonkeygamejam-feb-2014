require 'view/character'

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

  self.investments = {
    ['Shitty Job'] = 25,
    ['Student Loans'] = -1000
  }
end

function GameplayGameState:enter()
end

function GameplayGameState:update( dt )
  self.character:update( dt )
end

function GameplayGameState:draw()
  love.graphics.draw( self.background, 0, 0 )
  self.character:draw()

  --  Stats panel
  love.graphics.push()
    love.graphics.translate( self.stats.x, self.stats.y )

    love.graphics.setColor( self.stats.color )
    love.graphics.rectangle( 'fill', 0, 0, self.stats.width, self.stats.height )

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.printf( string.format( 'Your money: $%.02f', self.money ), 20, 20, self.stats.width - 40, 'left' )
    love.graphics.printf( string.rep( '-', 57 ), 20, 30, self.stats.width - 40, 'left' )
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