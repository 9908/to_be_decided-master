camera = {}
camera.x = 0
camera.y = 0
camera.sx = 1/(love.graphics.getWidth()/(25*16))
camera.sy = 1/(love.graphics.getHeight()/(19*16))
camera.rotation = 0
camera.speed = 50
camera.directionX = "left"
camera.directionY = "none"
camera.shiftX = 0
camera.shiftY = 0
camera.shakeX = 0
camera.shakeY = 0
camera.shakedir = 0
camera.shakeVal = 0
camera.shiftmax = 70
camera.shake = false
camera.shaketype = "none"


function camera:set(pX,pY)
  love.graphics.push()

  love.graphics.translate(pX, pY)
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.sx, 1 / self.sy)
  love.graphics.translate(-pX, -pY)

  love.graphics.translate(-self.x, -self.y)
end


function camera:update( dt , directionX, directionY )
  if not(camera.shaketype == "none") then
    camera.shake = true
  end

  if camera.shake then
    camera.shakeVal = camera.shakeVal + 30*dt

    if camera.shaketype == "explosion" then
      if camera.shakeVal > 2*math.pi then
        camera.shakeX = math.cos(camera.shakedir)*5*math.sin(camera.shakeVal)
        camera.shakeY = math.sin(camera.shakedir)*5*math.sin(camera.shakeVal)
      else
        camera.shakeX = math.cos(camera.shakedir)*10*math.sin(camera.shakeVal)
        camera.shakeY = math.sin(camera.shakedir)*10*math.sin(camera.shakeVal)
      end
      if camera.shakeVal > 4*math.pi then
        camera.shake = false
        camera.shakeX = 0
        camera.shakeY = 0
        camera.shakeVal = 0
        camera.shaketype = "none"
      end

    elseif camera.shaketype == "shooting" then
      camera.shakeX = math.cos(camera.shakedir)*math.sin(100*camera.shakeVal)
      camera.shakeY = math.sin(camera.shakedir)*math.sin(100*camera.shakeVal)
      if camera.shakeVal > 2*math.pi then
        camera.shake = false
        camera.shakeX = 0
        camera.shakeY = 0
        camera.shakeVal = 0
        camera.shaketype = "none"
      end
    end
  else
    self.directionX = directionX
    self.directionY = directionY

    if self.directionX == "left" then
      if self.shiftX > (-self.shiftmax/2) then
        self.shiftX = self.shiftX - dt*self.speed 
      end
    elseif self.directionX == "right" then
      if self.shiftX < self.shiftmax/2 then
        self.shiftX = self.shiftX + dt*self.speed
      end
    end 

    if self.directionY == "up" then
      if self.shiftY > (-self.shiftmax) then
        self.shiftY = self.shiftY - dt*self.speed 
      end
    elseif self.directionY == "down" then
      if self.shiftY < self.shiftmax then
        self.shiftY = self.shiftY + dt*self.speed
      end
    else
      if self.shiftY < 0 then
        self.shiftY = self.shiftY + dt*self.speed
        if self.shiftY > 0 then
          self.shiftY = 0
        end
      else 
        self.shiftY = self.shiftY - dt*self.speed
        if self.shiftY < 0 then
          self.shiftY = 0
        end
      end  
    end 
  end
end
function camera:unset()
  love.graphics.pop()
end

function camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function camera:scale(sx, sy)
  sx = sx or 1
  sy = sy or 1
  self.sx = self.sx * sx
  self.sy = self.sy * sy
end

function camera:reset()
	self.sx = 0.5
	self.sy = 0.5
	self.rotation = 0
end

function camera:setX(value)
  local mapWidth = screenWidth*self.sx
  local posScreenX = math.floor(player.x/mapWidth)*mapWidth
  currentscreenX = math.floor(player.x/mapWidth)  

  if self._bounds then
    --self.x = math.clamp(posScreenX + self.shiftX + self.shakeX , self._bounds.x1, self._bounds.x2)
    self.x = math.clamp(posScreenX + self.shakeX , self._bounds.x1, self._bounds.x2)
  else
    self.x = posScreenX
  end
end

function camera:setY(value)
  local mapHeight = screenHeight*self.sy
  local posScreenY = math.floor(player.y/mapHeight)*mapHeight
  currentscreenY = math.floor(player.y/mapHeight)
  if self._bounds then
    --self.y = math.clamp(value + self.shiftY + self.shakeY , self._bounds.y1, self._bounds.y2)
    self.y = math.clamp(posScreenY + self.shakeY , self._bounds.y1, self._bounds.y2)
  else
    self.y = posScreenY
  end
end

function camera:setPosition(x, y)
  if x then self:setX(x) end
  if y then self:setY(y) end

end

function camera:getPosition()
	return self.x, self.y
end

function camera:setScale(sx, sy)
  self.sx = sx or self.sx
  self.sy = sy or self.sy
end

function camera:getScaleX()
  return self.sx 
end

function camera:getBounds()
  return unpack(self._bounds)
end

function camera:setBounds(x1, y1, x2, y2)
  self._bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end