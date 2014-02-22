require 'view/character'

GameplayGameState = {}

function GameplayGameState:init()
  self.character = Character()
end

function GameplayGameState:enter()
end

function GameplayGameState:update( dt )
  self.character:update( dt )
end

function GameplayGameState:draw()
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