Character = Class {
  x = 0,
  y = 0,
  width = 80,
  height = 75,

  scaleX = 1,
  scaleY = 1,

  hitShape = nil,

  dead = false
}

Character.State = {
  Standing = {
    image = nil,
    batch = nil,
    quads = {},
    frame = 0,
    spriteWidth = 1,
    spriteHeight = 1,
    hitSizes = {
      {width = 41, height = 65},
      {width = 40, height = 66},
      {width = 38, height = 64},
      {width = 38, height = 62},
      {width = 38, height = 64},
      {width = 40, height = 65}
    }
  },
  Walking = {
    image = nil,
    batch = nil,
    quads = {},
    frame = 0,
    spriteWidth = 1,
    spriteHeight = 1,
    hitSizes = {
      {width = 32, height = 65},
      {width = 20, height = 66},
      {width = 27, height = 65},
      {width = 31, height = 65},
      {width = 19, height = 65},
      {width = 22, height = 66}
    }
  },
  Attacking = {
    image = nil,
    batch = nil,
    quads = {},
    frame = 0,
    spriteWidth = 1,
    spriteHeight = 1,
    hitSizes = {
      {width = 44, height = 54},
      {width = 48, height = 55},
      {width = 51, height = 54},
      {width = 45, height = 55},
      {width = 47, height = 57},
      {width = 52, height = 56},
      {width = 60, height = 50},
      {width = 60, height = 51},
      {width = 49, height = 54}
    }
  },
  Damage = {
    image = nil,
    batch = nil,
    quads = {},
    frame = 0,
    spriteWidth = 1,
    spriteHeight = 1,
    hitSizes = {
      {width = 46, height = 59},
      {width = 46, height = 63}
    }
  },
  Death = {
    image = nil,
    batch = nil,
    quads = {},
    frame = 0,
    spriteWidth = 1,
    spriteHeight = 1,
    hitSizes = {
      {width = 51, height = 56},
      {width = 56, height = 49},
      {width = 73, height = 27},
      {width = 75, height = 24}
    }
  }
}

Character.__name = 'Character'

local framerate, time, speedModifier = 1 / 12, 0, 2

local keyDown = {
  left = false,
  right = false,
  down = false,
  up = false,
  attack = false
}

function Character:__init( x, y, width, height, state )
  self.x = x or 0
  self.y = y or 0
  self.width = width or 80
  self.height = height or 75

  self.dead = false

  self.hitShape = Collider:addRectangle( self.x, self.y, self.width, self.height )
  self.hitShape.source = self

  self:setupState( Character.State.Standing, 'assets/images/stand.png', 6, 80, 75 )
  self:setupState( Character.State.Walking, 'assets/images/walk.png', 6, 80, 75 )
  self:setupState( Character.State.Attacking, 'assets/images/attack.png', 9, 80, 75 )
  self:setupState( Character.State.Damage, 'assets/images/death.png', 2, 80, 75 )
  self:setupState( Character.State.Death, 'assets/images/hurt.png', 4, 80, 75 )

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

  if self.state ~= Character.State.Standing or self.state ~= Character.State.Walking then
    keyDown.up = false
    keyDown.left = false
    keyDown.down = false
    keyDown.right = false
  end

  if self.state ~= Character.State.Death then
    self.dead = false
  end
end

function Character:getState()
  return self.state
end

function Character:canMove()
  local st = self:getState()
  return st ~= Character.State.Attacking and st ~= Character.State.Damage and st ~= Character.State.Death
end

function Character:getWidth()
  return self:getState().hitSizes[ self:getState().frame ].width
end

function Character:getHeight()
  return self:getState().hitSizes[ self:getState().frame ].height
end

function Character:update( dt )
  if self.dead then
    return
  end

  local st = self:getState()
  local char_width, char_height = self:getWidth(), self:getHeight()
  local offset_width, offset_height = (st.spriteWidth - char_width) * 0.5, (st.spriteHeight - char_height)
  local yMovementModifier = love.graphics.getHeight() / love.graphics.getWidth()
  local xMovementModifier = love.graphics.getWidth() / love.graphics.getHeight()

  --  Reset state if both up and down are pressed while both left and right are not pressed
  if keyDown.up and keyDown.down then
    keyDown.up = false
    keyDown.down = false
    if not keyDown.left and not keyDown.right then
      self:setState( Character.State.Standing )
    end
  end

  if keyDown.up then
    self.y = self.y - (char_height * speedModifier) * (dt * yMovementModifier)
    if self.y < -offset_height then
      self.y = -offset_height
    end
  end

  if keyDown.down then
    self.y = self.y + (char_height * speedModifier) * (dt * yMovementModifier)
    if self.y > love.graphics.getHeight() - st.spriteHeight then
      self.y = love.graphics.getHeight() - st.spriteHeight
    end
  end

  --  Reset state if both left and right are pressed while both up and down are not pressed
  if keyDown.left and keyDown.right then
    keyDown.left = false
    keyDown.right = false
    if not keyDown.up and not keyDown.down then
      self:setState( Character.State.Standing )
    end
  end

  if keyDown.left then
    self.scaleX = -1
    self.x = self.x - (char_width * speedModifier) * (dt * xMovementModifier)
    if self.x < -offset_width then
      self.x = -offset_width
    end
  end

  if keyDown.right then
    self.scaleX = 1
    self.x = self.x + (char_width * speedModifier) * (dt * xMovementModifier)
    if self.x > love.graphics.getWidth() - (st.spriteWidth - offset_width) then
      self.x = love.graphics.getWidth() - (st.spriteWidth - offset_width)
    end
  end

  Collider:remove( self.hitShape )
  local cx, cy = self.x + self:getState().spriteWidth * 0.5, self.y + self:getState().spriteHeight * 0.5
  local rx, ry = cx - self:getWidth() * 0.5, (cy + self:getState().spriteHeight * 0.5) - self:getHeight()
  self.hitShape = Collider:addRectangle( rx, ry, self:getWidth(), self:getHeight() )
  self.hitShape.source = self

  st.batch:bind()
  st.batch:clear()
  st.batch:add( st.quads[ st.frame ], 0, 0 )
  st.batch:unbind()

  time = time + dt
  if time >= framerate then
    st.frame = (st.frame % #st.quads) + 1
    time = 0
    if st.frame <= 1 then
      if keyDown.attack or st == Character.State.Damage then
        keyDown.attack = false
        self:setState( Character.State.Standing )
      elseif st == Character.State.Death then
        -- You dead, sucka
        self.dead = true
        Timer.add( 5, function()
          self:setState( Character.State.Standing )
        end )
      end
    end
  end
end

function Character:draw()
  love.graphics.push()
    love.graphics.translate( self.x, self.y )
    love.graphics.draw( self:getState().batch, 0, 0, 0, self.scaleX, self.scaleY, self.scaleX < 0 and self:getState().spriteWidth or 0 )

    local st = self:getState()
    local w, h = self:getWidth(), self:getHeight()
    love.graphics.setColor( 255, 0, 0 )
    love.graphics.rectangle( 'line', (st.spriteWidth - w) * 0.5, st.spriteHeight - h, w, h )
    love.graphics.setColor( 0, 255, 0 )
    love.graphics.rectangle( 'line', 0, 0, st.spriteWidth, st.spriteHeight )
  love.graphics.pop()

  love.graphics.push()
    love.graphics.setColor( 0, 0, 255 )
    self.hitShape:draw( 'line' )
  love.graphics.pop()
end

function Character:keypressed( key, isrepeat )
  if self:canMove() then
    if key == 'w' or key == 'up' then
      if self:getState() ~= Character.State.Walking then self:setState( Character.State.Walking ) end
      keyDown.up = true
    elseif key == 'a' or key == 'left' then
      if self:getState() ~= Character.State.Walking then self:setState( Character.State.Walking ) end
      keyDown.left = true
    elseif key == 's' or key == 'down' then
      if self:getState() ~= Character.State.Walking then self:setState( Character.State.Walking ) end
      keyDown.down = true
    elseif key == 'd' or key == 'right' then
      if self:getState() ~= Character.State.Walking then self:setState( Character.State.Walking ) end
      keyDown.right = true
    elseif key == ' ' then
      keyDown.attack = true
      self:setState( Character.State.Attacking )
    elseif key == 'kpenter' or key == 'return' then
      self:setState( self:getState() ~= Character.State.Damage and Character.State.Damage or Character.State.Standing )
    elseif key == 'z' then
      self:setState( self:getState() ~= Character.State.Death and Character.State.Death or Character.State.Standing )
    end
  end
end

function Character:keyreleased( key )
  if key == 'w' or key == 'up' then
    if self:canMove() and self:getState() ~= Character.State.Standing and not keyDown.left and not keyDown.right and not keyDown.down then self:setState( Character.State.Standing ) end
    keyDown.up = false
  elseif key == 'a' or key == 'left' then
    if self:canMove() and self:getState() ~= Character.State.Standing and not keyDown.up and not keyDown.right and not keyDown.down then self:setState( Character.State.Standing ) end
    keyDown.left = false
  elseif key == 's' or key == 'down' then
    if self:canMove() and self:getState() ~= Character.State.Standing and not keyDown.up and not keyDown.left and not keyDown.right then self:setState( Character.State.Standing ) end
    keyDown.down = false
  elseif key == 'd' or key == 'right' then
    if self:canMove() and self:getState() ~= Character.State.Standing and not keyDown.up and not keyDown.left and not keyDown.down then self:setState( Character.State.Standing ) end
    keyDown.right = false
  end
end
