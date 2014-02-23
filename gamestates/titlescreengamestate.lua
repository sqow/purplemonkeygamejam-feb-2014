TitleScreenGameState = {}

function TitleScreenGameState:init()
  self.color = {155, 50, 50}
end

function TitleScreenGameState:enter()
  self.color = {155, 50, 50}
end

function TitleScreenGameState:update( dt )
end

function TitleScreenGameState:draw()
  love.graphics.setBackgroundColor( self.color )

  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  local half_w, half_h = w * 0.5, h * 0.5

  love.graphics.setColor( 255, 255, 255 )
  love.graphics.printf( [[
You've rescued the kingdom (well, sort of). You've saved your beloved (if only you were theirs).

You killed to do so. You spent every penny you had and you lied, cheated, looted, stole, and even part-timed as an assassin to attain even more to spend.

You made a lot of new enemies and, now that you're out of the limelight, I'm not sure they'll hold back.

You were hailed as the hero, but that didn't last.
You were given medals and acclaim, but those didn't pay for food.

Now you're just trying to survive.
Get money. Get food. Get water. Get drinks.
You've gone through too much to die destitute.



PAY ATTENTION TO YOUR RESOURCES IN THE BOTTOM BAR! You know, because they're important.
]], half_w * 0.5, half_h * 0.5, half_w, 'center' )
  love.graphics.printf( 'Press <enter> to continue', half_w * 0.5, h - 50, half_w, 'center' )
end

function TitleScreenGameState:focus( focus )
end

function TitleScreenGameState:keypressed( key, isrepeat )
end

function TitleScreenGameState:keyreleased( key )
  if key == 'kpenter' or key == 'return' then
    Timer.tween( 0.75, self.color, {55, 0, 0}, 'out-quad', function()
      Gamestate.switch( State.Gameplay )
    end )
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