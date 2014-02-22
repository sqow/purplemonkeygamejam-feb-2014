Character = Class {
  x = 0,
  y = 0,
  width = 70,
  height = 70,

  scaleX = 1,
  scaleY = 1
}

Character.State = {
  Standing = {
    image = nil,
    batch = nil,
    quads = {},
    frame = 0,
    spriteWidth = 1,
    spriteHeight = 1
  },
  Walking = {
    image = nil,
    batch = nil,
    quads = {},
    frame = 0,
    spriteWidth = 1,
    spriteHeight = 1
  }
}

Character.__name = 'Character'

local framerate, time = 1 / 12, 0

local keyDown = {
  left = false,
  right = false,
  down = false,
  up = false
}

function Character:__init( x, y, width, height, state )
  self.x = x or 0
  self.y = y or 0
  self.width = width or 70
  self.height = height or 70

  self:setupState( Character.State.Standing, 'assets/images/stand.png', 6, 42, 66 )
  self:setupState( Character.State.Walking, 'assets/images/walk.png', 6, 42, 66 )

  self:setState( state or Character.State.Standing )
end

function Character:setupState( state, imgFilename, numSprites, spriteWidth, spriteHeight )
  state.image = love.graphics.newImage( imgFilename )
  state.batch = love.graphics.newSpriteBatch( state.image, numSprites, 'stream' )

  state.spriteWidth = spriteWidth
  state.spriteHeight = spriteHeight

  for i = 1, numSprites do
    state.quads[i] = love.graphics.newQuad( (i-1) * spriteWidth, 0, spriteWidth, spriteHeight, spriteWidth * numSprites, spriteHeight )
  end

  state.frame = 1
end

function Character:setState( state )
  self.state = state or Character.State.Standing
  self.state.frame = 1
end

function Character:getState()
  return self.state
end

function Character:update( dt )
  if keyDown.up then
    self.y = math.max( self.y - (self.state.spriteHeight * 3) * dt, 0 )
  end

  if keyDown.down then
    self.y = math.min( self.y + (self.state.spriteHeight * 3) * dt, love.graphics.getHeight() - self.state.spriteHeight )
  end

  if keyDown.left then
    self.scaleX = -1
    self.x = math.max( self.x - (self.state.spriteWidth * 3) * dt, 0 )
  end

  if keyDown.right then
    self.scaleX = 1
    self.x = math.min( self.x + (self.state.spriteWidth * 3) * dt, love.graphics.getWidth() - self.state.spriteWidth )
  end

  self.state.batch:bind()
  self.state.batch:clear()
  self.state.batch:add( self.state.quads[ self.state.frame ], 0, 0 )
  self.state.batch:unbind()

  time = time + dt
  if time >= framerate then
    self.state.frame = (self.state.frame % #self.state.quads) + 1
    time = 0
  end
end

function Character:draw()
  love.graphics.draw( self.state.batch, self.x, self.y, 0, self.scaleX, self.scaleY, self.scaleX < 0 and self.state.spriteWidth or 0 )
end

function Character:keypressed( key, isrepeat )
  if key == 'w' or key == 'up' then
    if self.state ~= Character.State.Walking then self:setState( Character.State.Walking ) end
    keyDown.up = true
  elseif key == 'a' or key == 'left' then
    if self.state ~= Character.State.Walking then self:setState( Character.State.Walking ) end
    keyDown.left = true
  elseif key == 's' or key == 'down' then
    if self.state ~= Character.State.Walking then self:setState( Character.State.Walking ) end
    keyDown.down = true
  elseif key == 'd' or key == 'right' then
    if self.state ~= Character.State.Walking then self:setState( Character.State.Walking ) end
    keyDown.right = true
  end
end

function Character:keyreleased( key )
  if key == 'w' or key == 'up' then
    if self.state ~= Character.State.Standing and not keyDown.left and not keyDown.right and not keyDown.down then self:setState( Character.State.Standing ) end
    keyDown.up = false
  elseif key == 'a' or key == 'left' then
    if self.state ~= Character.State.Standing and not keyDown.up and not keyDown.right and not keyDown.down then self:setState( Character.State.Standing ) end
    keyDown.left = false
  elseif key == 's' or key == 'down' then
    if self.state ~= Character.State.Standing and not keyDown.up and not keyDown.left and not keyDown.right then self:setState( Character.State.Standing ) end
    keyDown.down = false
  elseif key == 'd' or key == 'right' then
    if self.state ~= Character.State.Standing and not keyDown.up and not keyDown.left and not keyDown.down then self:setState( Character.State.Standing ) end
    keyDown.right = false
  elseif key == 'return' then
    self:setState( self:getState() == Character.State.Standing and Character.State.Walking or Character.State.Standing )
  end
end