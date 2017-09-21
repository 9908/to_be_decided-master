-- Subclass of Entity
require("entity")

-- constants values for speeds for Sheep
SPEED_MAX = 50 -- Lateral constant speed (MRU)
SPEED = 50
FLYSPEED = 500 
JUMP_DAMP = 3

sheeps = {}
SheepClass =  Entity:new()

function SummonSheeps(local_x,local_y,nbr) -- Spawn new Sheeps
	
	for i = 1,nbr do
		local newSheep = SheepClass:new{	
					x = local_x + i * 3 , y = local_y, x_vel = SPEED, y_vel = 0, 
					h = 25, w = 30, img = love.graphics.newImage('assets/lvl1/Sheep1.png'), 
					standing = false, relativepos = 0, onslope = "false", state = "" , grabber = nil, immobile = false
		}
		table.insert(sheeps, newSheep)
	end
end



function SheepClass:stepX( nextX ) 
	local x_col -- coordinate of the forward-facing edge
	if self.x_vel > 0 then -- facing right
		x_col = nextX + self.w/2
	elseif self.x_vel < 0 then  -- facing left
		x_col = nextX - self.w/2
	end

	local distX = self:stepXentity(nextX)

	if distX == 0 then
		self.immobile = true
	else 
		self.immobile = false	
	end

	return distX
end

function SheepClass:stepY( nextY )
	local y_col -- coordinate of the forward-facing edge

	if self.y_vel < 0 then -- facing up
		y_col = nextY - self.h/2
	else 				  -- facing down
		y_col = nextY + self.h/2
	end

	local  distY = self:stepYentity(nextY)

	return distY
end

function SheepClass:hit() 
	self.x_vel = -SPEED_MAX
	self.y_vel = self.y_vel - 350
	hitsheep_SFX:play()
end


function SheepClass:basicIA() 
	if not(self.grabber == nil) then
		self.x = self.grabber.x
		self.y = self.grabber.y - self.grabber.h/2 - self.h/2
	else
		if self.x_vel == 0 then
			self.x_vel = -SPEED_MAX
		elseif self.immobile then
			self.x_vel = -self.x_vel
		end 
	end

end

function SheepClass:updateSheep(dt) -- Update a single Sheep
	self:basicIA()
end

function updateSheeps(dt)			-- Update all Sheepies
	for i, Sheep in ipairs(sheeps) do

		Sheep:update(dt)
		Sheep:updateSheep(dt)
	end
end

function SheepClass:draw()
		if debug == true then
			love.graphics.setColor(40,0,255)
			love.graphics.rectangle("fill", self.x - self.w/2, self.y - self.h/2, self.w, self.h) -- hitbox
			love.graphics.setColor(255,255,255)

			love.graphics.printf("grabber: ".. tostring(self.grabber), 0, self.y - 80,self.x+100,"center") -- Display dt

		end

		love.graphics.draw(self.img,self.x-self.w/2*self.x_vel/math.abs(self.x_vel),self.y - self.h/2,0,self.x_vel/math.abs(self.x_vel),1)


end

function drawSheeps()
	-- Draw sheeps
	for i, Sheep in ipairs(sheeps) do
		Sheep:draw()
	end
end
