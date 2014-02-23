Class = require 'libs/30log'
require 'libs/Beetle'
Gamestate = require 'libs/hump/gamestate'
Timer = require 'libs/hump/timer'
HC = require 'libs/hardoncollider'

local gstitle = require 'gamestates/titlescreengamestate'
local gsgameplay = require 'gamestates/gameplaygamestate'
local gsgameend = require 'gamestates/gameendgamestate'

State = {
  Title = gstitle,
  Gameplay = gsgameplay,
  End = gsgameend
}

--  Main functions

function love.load( arg )
  beetle.load()
  beetle.setKey( '`' )
  
  math.randomseed( os.time() )

  Gamestate.registerEvents()
  Gamestate.switch( State.Title )

  love.graphics.setBackgroundColor( 255, 255, 255 )

  love.graphics.setFont( love.graphics.newFont(14) )
end

function love.update( dt )
  Timer.update( dt )
end

function love.draw()
  beetle.draw()
end

--  Key and text input handling

function love.keypressed( key, isrepeat )
  if key == 'escape' then
    love.event.push( 'quit' )
  end
end

function love.keyreleased( key )
  beetle.key( key )
end

function love.textinput( text )
end

--  Mouse handling

function love.mousepressed( x, y, button )
end

function love.mousereleased( x, y, button )
end

--  Focus handling

function love.focus( f )
end

function love.mousefocus( f )
end

function love.visible( v )
end

--  Resize handling

-- function love.resize( w, h )
-- end

--  Main loop & ending func

-- function love.run()
-- end

-- function love.quit()
-- end

--  Error handling

-- function love.errhand( msg )
-- end

-- function love.threaderror( thread, errorstr )
-- end

function beginContact( a, b, coll )

end

function endContact( a, b, coll )
  
end

function preSolve( a, b, coll )

end

function postSolve( a, b, coll )
  
end
