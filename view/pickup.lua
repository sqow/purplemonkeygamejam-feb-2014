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
  hitShape = nil
}

Pickup.__name = 'Pickup'

local fullAlpha = 255 * 0.85
local fadedAlpha = 255 * 0.65

Pickup.Type = {
  Money = {
    color = {255, 255, 0, fullAlpha},
    faded = {255, 255, 0, fadedAlpha},
    label = 'M'
  },
  Food = {
    color = {255, 0, 0, fullAlpha},
    faded = {255, 0, 0, fadedAlpha},
    label = 'F'
  },
  Water = {
    color = {0, 0, 255, fullAlpha},
    faded = {0, 0, 255, fadedAlpha},
    label = 'W'
  }--[[,
  Drink = {
    color = {0, 255, 0, fullAlpha},
    faded = {0, 255, 0, fadedAlpha},
    label = 'D'
  }]]
}

function Pickup:__init( x, y, width, height, pickupType, value )
  self.x = x or 0
  self.y = y or 0
  self.width = width or 20
  self.height = height or 20

  pickupType = pickupType or Pickup.Type.Money
  self.real_color = pickupType.color
  self.color = pickupType.color
  self.faded = pickupType.faded
  self.ptype = pickupType

  self.value = value or 0

  self.hitShape = Collider:addCircle( self.x, self.y, math.max( self.width, self.height ) )
  self.hitShape.source = self
end

function Pickup:update( dt )
end

function Pickup:draw()
  love.graphics.push()
    --love.graphics.translate( self.x, self.y )

    love.graphics.setColor( self.color )

    --love.graphics.circle( 'fill', 0, 0, math.max( self.width, self.height ) )
    self.hitShape:draw( 'fill' )

    local icolor = {
      math.abs( 255 - self.color[1] ),
      math.abs( 255 - self.color[2] ),
      math.abs( 255 - self.color[3] ),
      self.color[4]
    }

    local ir, ig, ib, ia = unpack( icolor )
    local r, g, b, a = unpack( self.color )
    love.graphics.setColor( icolor )
    love.graphics.printf( self.ptype.label, self.x - self.width * 0.5, self.y - self.height * 0.8, self.width, 'center' )
  love.graphics.pop()
end