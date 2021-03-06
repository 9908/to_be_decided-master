-- Subclass of Entity
require("entity")
require("sheep")

-- constants values for speeds for ennemy
SPEED_MAX = 50 -- Lateral constant speed (MRU)
SPEED = 50
HEALTH = 4	-- number of lives
FLYSPEED = 500 
JUMP_DAMP = 3

ATTENTION_SPAN = 5 -- Ennemy stops chasing the player when he stopped detecting him during ATTENTION_SPAN seconds

ennemies = {}
EnnemyClass =  Entity:new()

function SummonEnnemies(local_x,local_y,nbr) -- Spawn new Ennemies
	
	for i = 1,nbr do
		local newEnnemy = EnnemyClass:new{	
					x = local_x + math.mod(i,5) * 33, y = local_y - i * 11, x_vel = SPEED, y_vel = 0, 
					h = 26, w = 11, img = love.graphics.newImage('assets/lvl1/ennemy1.png'), 
					standing = false, relativepos = 0, onslope = "false", state = "" ,
					health = HEALTH, timerDetection = love.timer.getTime(), sheep_grabbed = nil 	
		}
		table.insert(ennemies, newEnnemy)
	end
end

function EnnemyClass:hit(damage,local_y,towards_right,table_id)
	self.health = self.health - damage;
	hit_SFX:play()

	if self.health < 0 then
		if not(self.sheep_grabbed == nil) then
			self.sheep_grabbed.grabber = nil
			self.sheep_grabbed = nil
		end	
		table.remove(ennemies,table_id)
		score = score + 1
	end
	collision = true
	animImg = newAnimation(love.graphics.newImage("assets/weapon/hit_explosion.png"), 32, 31, 0.07, 0) -- TODO SHOULD BE INITIATED ONLY ONCE
	animImg:setMode("once")

	if towards_right == 1 then
		table.insert(anims,{ x = self.x  -	self.w - 32/2 , y = local_y-32/2  , animation = animImg, scaleX = 1, scaleY = 1})
		--ennemy.x_vel = 10 -- TODO VECTOR MOVEMENT
	else
		table.insert(anims,{ x = self.x + 2*self.w+32/2, y = local_y+32/2 , animation = animImg, scaleX = -1, scaleY = 1})
		--ennemy.x_vel = -10 -- TODO VECTOR MOVEMENT
	end
end

function EnnemyClass:checkXcollisionsWithPlayer(x_col)
	local collidingPlayer = nil
	local ychecking_pos = {self.y-self.h/2+1, self.y+self.h/2-1}

	for j = 1,2,1 do
		if Point_Rectangle_CollisionCheck(x_col,ychecking_pos[j], player.x,player.y,player.w,player.h) == true then
			collidingPlayer = player
		end
	end

	return collidingPlayer
end

function EnnemyClass:checkYcollisionsWithPlayer(y_col)
	local collidingPlayer = nil
	local xchecking_pos = {self.x-self.w/2+1, self.x+self.w/2-1}

	for j = 1,2,1 do
		if Point_Rectangle_CollisionCheck(xchecking_pos[j], y_col, player.x,player.y,player.w,player.h) == true then
			collidingPlayer = player
		end
	end

	return collidingPlayer
end

function EnnemyClass:checkcollisionsWithSheep()

	for i, sheep in ipairs(sheeps) do
		if Point_Rectangle_CollisionCheck(self.x,self.y, sheep.x,sheep.y,sheep.w,sheep.h) == true then
			if sheep.grabber == nil then
				self.sheep_grabbed = sheep
				sheep.grabber = self
				hitsheep_SFX:play()
				return sheep_local
			end
		end
	end

	return nil
end

function EnnemyClass:stepX( nextX ) 
	local x_col -- coordinate of the forward-facing edge
	if self.x_vel > 0 then -- facing right
		x_col = nextX + self.w/2
	elseif self.x_vel < 0 then  -- facing left
		x_col = nextX - self.w/2
	end

	local distX = self:stepXentity(nextX)
	local player_local = self:checkXcollisionsWithPlayer(x_col)

	if not(player_local == nil) then
		if self.x_vel > 0 then
			distX = player_local.x-player_local.w/2 - (self.x + self.w/2)
		else
			distX = player_local.x+player_local.w/2 - (self.x - self.w/2) 
		end

	end

	return distX
end

function EnnemyClass:stepY( nextY )
	local y_col -- coordinate of the forward-facing edge

	if self.y_vel < 0 then -- facing up
		y_col = nextY - self.h/2
	else 				  -- facing down
		y_col = nextY + self.h/2
	end

	local  distY = self:stepYentity(nextY)
	
	local player_local = self:checkYcollisionsWithPlayer(y_col)

	if not(player_local == nil) then
		if self.y_vel > 0 then
			distY = player_local.y-player_local.h/2 - (self.y + self.h/2)
		else
			distY = player_local.y+player_local.h/2 - (self.y - self.h/2) 
		end
		distY = 0

	end

	return distY
end

function EnnemyClass:chasePlayerIA() 

	local random = math.random(0,1000)

	if random > 500 and not(self.x_vel == 0) and self.y_vel == 0 then -- Randomly jumps when moving towards
		self.y_vel = -(random-500)/JUMP_DAMP
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

function EnnemyClass:chaseSheepsIA() 

	local random = math.random(0,1000)

	if random > 500 and not(self.x_vel == 0) and self.y_vel == 0 then -- Randomly jumps when moving towards
		self.y_vel = -(random-500)/(JUMP_DAMP/1.5)
	end

	if self.sheep_grabbed == nil then
		self:checkcollisionsWithSheep()
	end

	if self.sheep_grabbed == nil then
		self.x_vel = -SPEED
	else 
		self.x_vel = SPEED
	end

end

function EnnemyClass:updateEnnemy(dt) -- Update a single ennemy
	--self:chasePlayerIA()
	self:chaseSheepsIA()
	if self.x_vel > 0 and self.x_vel < SPEED_MAX then -- TODO VECTOR MOVEMENT
		self.x_vel = self.x_vel + SPEED*dt
	elseif self.x_vel < 0 and self.x_vel > -SPEED_MAX then
		self.x_vel = self.x_vel - SPEED*dt
	end
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
			love.graphics.draw(self.img,self.x-self.w/2 - 5,self.y - self.h/2 )
		else 
			love.graphics.draw(self.img,self.x-self.w/2 + 17,self.y - self.h/2 ,0,-1,1)
		end

end

function drawEnnemies()
	-- Draw Ennemies
	for i, ennemy in ipairs(ennemies) do
		ennemy:draw()
	end
end
