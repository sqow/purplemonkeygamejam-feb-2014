Enemy = Class {
  x = 0,
  y = 0,
  width = 80,
  height = 75,

  scaleX = 1,
  scaleY = 1,

  hitShape = nil,

  dead = false,
  dying = false,
  speedModifier = 0
}

Enemy.State = {
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
      {width = 46, height = 63},
      {width = 46, height = 59},
      {width = 46, height = 63},
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

Enemy.__name = 'Enemy'

function Enemy:__init( x, y, width, height, state )
  self.x = x or 0
  self.y = y or 0
  self.width = width or 80
  self.height = height or 75

  self.dying = false
  self.dead = false

  self.target = nil

  self.hitShape = Collider:addRectangle( self.x, self.y, self.width, self.height )
  self.hitShape.source = self

  self:setupState( Enemy.State.Standing, 'assets/images/stand.png', 6, 80, 75 )
  self:setupState( Enemy.State.Walking, 'assets/images/walk.png', 6, 80, 75 )
  self:setupState( Enemy.State.Attacking, 'assets/images/attack.png', 9, 80, 75 )
  self:setupState( Enemy.State.Damage, 'assets/images/death.png', 6, 80, 75 )
  self:setupState( Enemy.State.Death, 'assets/images/hurt.png', 4, 80, 75 )

  self.speedModifier = math.random( 0.8, 1.2 )

  self.speed = {
    x = math.random( 5 ) * self.speedModifier,
    y = math.random( 5 ) * self.speedModifier
  }

  self.framerate = 1/12
  self.time = 0

  self:setState( state or Enemy.State.Walking )
end

function Enemy:setupState( state, imgFilename, numSprites, spriteWidth, spriteHeight )
  state.image = love.graphics.newImage( imgFilename )
  state.batch = love.graphics.newSpriteBatch( state.image, numSprites, 'stream' )

  state.spriteWidth = spriteWidth
  state.spriteHeight = spriteHeight

  for i = 1, numSprites do
    state.quads[i] = love.graphics.newQuad( (i-1) * spriteWidth, 0, spriteWidth, spriteHeight, spriteWidth * numSprites, spriteHeight )
  end

  state.frame = 1
end

function Enemy:setState( state )
  if state == self:getState() then
    return
  end

  self.state = state or Enemy.State.Standing
  self.state.frame = 1

  if self.state ~= Enemy.State.Death then
    self.dead = false
  elseif not self.dying then
    self.dying = true
  end
end

function Enemy:getState()
  return self.state
end

function Enemy:getWidth()
  return self:getState().hitSizes[ self:getState().frame ].width
end

function Enemy:getHeight()
  return self:getState().hitSizes[ self:getState().frame ].height
end

function Enemy:update( dt, char )
  if self.dead then
    return
  end

  local st = self:getState()
  local cst = char:getState()
  local ew, eh = self:getWidth(), self:getHeight()
  local cw, ch = char:getWidth(), char:getHeight()
  local eow, eoh = (st.spriteWidth - ew) * 0.5, (st.spriteHeight - eh)
  local cow, coh = (cst.spriteWidth - cw) * 0.5, (cst.spriteHeight - ch)
  local ex, ey = self.x + eow, self.y + eoh
  local cx, cy = char.x + cow, char.y + coh
  local yMovementModifier = love.graphics.getHeight() / love.graphics.getWidth()
  local xMovementModifier = love.graphics.getWidth() / love.graphics.getHeight()
  local dx, dy = cx - ex, cy - ey

  if st == Enemy.State.Walking then
    if self.target then
      dx = self.target[1] - ex
      dy = self.target[2] - ey
    end

    local mx = math.clamp((dx * dt), -0.25, 0.25) * self.speedModifier
    local my = math.clamp((dy * dt), -0.25, 0.25) * self.speedModifier

    self.x = self.x + mx
    self.y = self.y + my

    if self.target and math.round(self.x) == math.round(self.target[1]) and math.round(self.y) == math.round(self.target[2]) then
      self.target = nil
    end

    self.scaleX = dx > 0 and 1 or -1
    
    Collider:remove( self.hitShape )
    local cx, cy = self.x + self:getState().spriteWidth * 0.5, self.y + self:getState().spriteHeight * 0.5
    local rx, ry = cx - self:getWidth() * 0.5, (cy + self:getState().spriteHeight * 0.5) - self:getHeight()
    self.hitShape = Collider:addRectangle( rx, ry, self:getWidth(), self:getHeight() )
    self.hitShape.source = self
  end

  st.batch:bind()
  st.batch:clear()
  st.batch:add( st.quads[ st.frame ], 0, 0 )
  st.batch:unbind()

  self.time = self.time + dt
  if self.time >= self.framerate then
    st.frame = (st.frame % #st.quads) + 1
    self.time = 0
    if st.frame <= 1 then
      if st == Enemy.State.Attacking or st == Enemy.State.Damage then
        self:setState( Enemy.State.Walking )
      elseif st == Enemy.State.Death then
        -- You dead, sucka
        self.dead = true
        self.dying = false
      end
    end
  end
end

function Enemy:draw()
  love.graphics.push()
    love.graphics.translate( self.x, self.y )
    love.graphics.setColor( 255, 0, 0 )
    love.graphics.draw( self:getState().batch, 0, 0, 0, self.scaleX, self.scaleY, self.scaleX < 0 and self:getState().spriteWidth or 0 )
  love.graphics.pop()
end
