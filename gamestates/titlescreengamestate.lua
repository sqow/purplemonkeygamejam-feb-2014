TitleScreenGameState = {}

function TitleScreenGameState:init()
end

function TitleScreenGameState:enter()
end

function TitleScreenGameState:update( dt )
end

function TitleScreenGameState:draw()
  love.graphics.setBackgroundColor( 155, 50, 50 )

  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local half_w, half_h = w * 0.5, h * 0.5

  love.graphics.setColor( 255, 255, 255 )
  love.graphics.printf( '"You win! ...now what?"', 0, half_h - 50, w, 'center' )
  love.graphics.printf( 'Press <enter> to continue', 0, half_h + 50, w, 'center' )
end

function TitleScreenGameState:focus( focus )
end

function TitleScreenGameState:keypressed( key, isrepeat )
end

function TitleScreenGameState:keyreleased( key )
  if key == 'kpenter' or key == 'return' then
    Gamestate.switch( State.Gameplay )
  end
end

function TitleScreenGameState:mousepressed( x, y, button )
end

function TitleScreenGameState:mousereleased( x, y, button )
end

function TitleScreenGameState:leave()
  love.graphics.setBackgroundColor( 255, 255, 255 )
end

return TitleScreenGameState