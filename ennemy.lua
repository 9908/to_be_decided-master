-- Subclass of Entity
require("entity")

-- constants values for speeds for ennemy
SPEED = 50	
HEALTH = 4
FLYSPEED = 500
 	
 ATTENTION_SPAN = 5

ennemies = {}
EnnemyClass =  Entity:new()

function SummonEnnemies(nbr) -- Spawn new Ennemies
	
	for i = 1,nbr do
		local newEnnemy = EnnemyClass:new{	
					x = 200 + i * 33 + love.graphics.getWidth()/2, y = 195, x_vel = SPEED, y_vel = 0, 
					h = 16, w = 11, img = love.graphics.newImage('assets/lvl1/ennemy1.png'), 
					standing = false, relativepos = 0, onslope = "false", state = "" ,
					health = HEALTH, timerDetection = love.timer.getTime() 	
		}
		table.insert(ennemies, newEnnemy)
	end
end

function EnnemyClass:stepX( nextX ) 
	local x_col -- coordinate of the forward-facing edge
	if self.x_vel > 0 then -- facing right
		x_col = nextX + self.w/2
	elseif self.x_vel < 0 then  -- facing left
		x_col = nextX - self.w/2
	end

	local intersecting_tiles = self:checkXcollisions(x_col)

	-- Check which obstacle is the closest (in this case they are all at the same distance)
	local distX = nextX - self.x

	for i, tile in ipairs(intersecting_tiles) do
		--print("tile - x: " .. tile.x .. " , y: " .. tile.y .. " , y0: " .. tostring(tile.y0) .. " , y1: " .. tostring(tile.y1))
		if self.onslope == "right" then 
			if self.x_vel > 0 and tile.y0 <= tile.y1 and (tile.y*map.tileHeight+tile.y0) < self.y then -- facing right
				distX = tile.x*map.tileWidth - (self.x + self.w/2) 
			elseif self.x_vel < 0 and tile.y0 == tile.y1 and (tile.x+1)*map.tileWidth < self.x then  -- facing left and tile.y0 < tile.y1
				distX = (tile.x+1)*map.tileWidth - (self.x - self.w/2) 
			end
		elseif self.onslope == "left" then 
			if self.x_vel > 0 and tile.y0 == tile.y1 and (tile.x)*map.tileWidth > self.x  then -- facing right
				distX = tile.x*map.tileWidth - (self.x + self.w/2) 
			elseif self.x_vel < 0 and tile.y0 >= tile.y1 and (tile.y*map.tileHeight+tile.y0) < self.y then  -- facing left and tile.y0 < tile.y1
				distX = (tile.x+1)*map.tileWidth - (self.x - self.w/2) 
			end	
		else 	
			if self.x_vel > 0 and tile.y0 <= tile.y1 then -- facing right
				distX = tile.x*map.tileWidth - (self.x + self.w/2) 
			elseif self.x_vel < 0 and tile.y0 >= tile.y1 then  -- facing left and tile.y0 < tile.y1
				distX = (tile.x+1)*map.tileWidth - (self.x - self.w/2) 
			end
		end
	end

	if distX == 0 then -- no X movement
		self.x_vel = - self.x_vel
	end

	return distX
end

function EnnemyClass:basicIA() 

	local random = math.random(0,1000)

	if random > 500 and not(self.x_vel == 0) and self.y_vel == 0 then -- Randomly jumps when moving towards
		self.y_vel = -(random-500)/2
	end

	if math.abs(player.x - self.x) < 100 and math.abs(player.y - self.y) < 50 then -- Player detection at in a rectangle of 100 in x and 10 in y
		if player.x > self.x then
			self.x_vel = SPEED
		else
			self.x_vel = -SPEED
		end
		self.timerDetection = love.timer.getTime()
	elseif math.abs(player.x - self.x) > 150 or math.abs(player.y - self.y) > 60 then-- Lose player detection at a radius of 100
		if love.timer.getTime() - self.timerDetection > ATTENTION_SPAN then	-- Ennemy stops chasing the player when he stopped detecting him during ATTENTION_SPAN seconds
			self.x_vel = 0
		end
	end	

end

function EnnemyClass:updateEnnemy(dt) -- Update a single ennemy
	self:basicIA()
end

function updateEnnemies(dt)			-- Update all ennemyies
	for i, ennemy in ipairs(ennemies) do

		ennemy:update(dt)
		ennemy:updateEnnemy(dt)
	end
end

function EnnemyClass:draw()
		if debug == true then
			love.graphics.setColor(100,40,155)
			love.graphics.rectangle("fill", self.x - self.w/2, self.y - self.h/2, self.w, self.h) -- hitbox
			love.graphics.setColor(255,255,255)

			love.graphics.setColor(255,0,0)
			for i = 1,self.health do
				love.graphics.rectangle("fill", self.x - self.w/2, self.y - self.h/2-i*12,12,6) -- lives
			end
			love.graphics.setColor(255,255,255)
		end
		if self.x_vel < 0 then 
			love.graphics.draw(self.img,self.x-self.w/2 - 5,self.y - self.h/2 - 10)
		else 
			love.graphics.draw(self.img,self.x-self.w/2 + 17,self.y - self.h/2 - 10,0,-1,1)
		end

end

function drawEnnemies()
	-- Draw Ennemies
	for i, ennemy in ipairs(ennemies) do
		ennemy:draw()
	end
end
