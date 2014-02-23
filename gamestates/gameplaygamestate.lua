require 'view/character'

GameplayGameState = {}

local background = nil

function GameplayGameState:init()
  self.character = Character()
  self.background = love.graphics.newImage( 'assets/images/background.jpg' )
end

function GameplayGameState:enter()
end

function GameplayGameState:update( dt )
  self.character:update( dt )
end

function GameplayGameState:draw()
  love.graphics.draw( self.background, 0, 0 )
  self.character:draw()
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
end

return GameplayGameState