Pickup = Class {
  x = 0,
  y = 0,
  width = 20,
  height = 20,
  real_color = {0, 255, 0, 255 * 0.85},
  color = {0, 255, 0, 255 * 0.85},
  faded = {0, 255, 0, 255 * 0.65},
  key = '',
  value = 0,
  tweening = false
}

Pickup.__name = 'Pickup'

local goToFaded, goToReal

goToFaded = function( pickup )
  Timer.tween( 0.5, pickup, {color=pickup.faded}, 'in-bounce', function() goToReal( pickup ) end )
end

goToReal = function( pickup )
  Timer.tween( 0.5, pickup, {color=pickup.real_color}, 'in-bounce', function() goToFaded( pickup ) end )
end

function Pickup:__init( x, y, width, height, color, faded, key, value )
  self.x = x or 0
  self.y = y or 0
  self.width = width or 20
  self.height = height or 20
  self.real_color = color or {0, 255, 0, 255 * 0.85}
  self.color = color or {0, 255, 0, 255 * 0.85}
  self.faded = faded or {0, 205, 0, 255 * 0.65}
  self.key = key or ''
  self.value = value or 0
  self.tweening = false

  Timer.add( math.random(), function() goToFaded( self ) end )
end

function Pickup:update( dt )
  
end

function Pickup:draw()
  love.graphics.push()
    love.graphics.translate( self.x, self.y )

    love.graphics.setColor( self.color )

    love.graphics.circle( 'fill', 0, 0, math.max( self.width, self.height ) )
  love.graphics.pop()
end