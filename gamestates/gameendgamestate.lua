GameEndGameState = {}

function GameEndGameState:init()
  self.color = {155, 50, 50}
end

function GameEndGameState:enter()
  self.color = {155, 50, 50}
end

function GameEndGameState:update( dt )
end

function GameEndGameState:draw()
  love.graphics.setBackgroundColor( self.color )

  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local half_w, half_h = w * 0.5, h * 0.5

  love.graphics.setColor( 255, 255, 255 )
  love.graphics.printf( [[
You died.
You either starved or became too dehydrated.
Maybe you were beaten to death.

Whatever it was, I bet it wasn't fun.
]], half_w * 0.5, half_h * 0.5, half_w, 'center' )
  love.graphics.printf( 'Press <enter> to continue', half_w * 0.5, h - 50, half_w, 'center' )
end

function GameEndGameState:focus( focus )
end

function GameEndGameState:keypressed( key, isrepeat )
  if key == 'kpenter' or key == 'return' then
    Timer.tween( 0.75, self.color, {55, 0, 0}, 'out-quad', function()
      Gamestate.switch( State.Gameplay )
    end )
  end
end

function GameEndGameState:keyreleased( key )
end

function GameEndGameState:mousepressed( x, y, button )
end

function GameEndGameState:mousereleased( x, y, button )
end

function GameEndGameState:leave()
  love.graphics.setBackgroundColor( 255, 255, 255 )
end

return GameEndGameState