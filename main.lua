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

function math.round( val )
  local lower = math.ceil( val - 1 )
  local higher = math.floor( val + 1 )
  local ld, hd = val - lower, higher - val

  if ld > hd then
    return higher
  elseif ld < hd then
    return lower
  else
    return val
  end
end

function math.randomRange( min, max )
  min = min or 0
  max = max or 1
  return min + math.random() * (max - min)
end

function math.randomInt( min, max )
  min = min or 0
  max = max or 1
  return math.round( math.randomRange( min, max ) )
end

function math.norm( val, min, max )
  return (val - min) / (max - min)
end

function math.lerp( norm, min, max )
  return min + (max - min) * norm
end

function math.map( val, srcMin, srcMax, dstMin, dstMax )
  return math.lerp( math.norm( val, srcMin, srcMax ), dstMin, dstMax )
end

function math.clamp( val, min, max )
  return math.min( math.max( val, math.min( min, max ) ), math.max( min, max ) )
end

--  Main functions

function love.load( arg )
  beetle.load()
  beetle.setKey( '`' )
  
  math.randomseed( os.time() )

  Collider = HC(100)

  Gamestate.registerEvents()
  Gamestate.switch( State.Title )

  love.graphics.setBackgroundColor( 255, 255, 255 )

  love.graphics.setFont( love.graphics.newFont(14) )
end

function love.update( dt )
  Timer.update( dt )
  Collider:update( dt )
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
