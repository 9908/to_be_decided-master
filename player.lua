-- Subclass of Entity

require("entity")
require("ennemy")

-- constants values for speeds for player 
WALK = 140			-- Walk speed
INIT_WALK = 5		-- Initial distance before starting to run
END_RUN_DAMP = 1000	-- Damping to stop
MAX_YSPEED = 200	-- Maximum falling speed
JUMP_VERT = -250	-- Jump velocity
JUMP_TIME_MAX = 135	-- Max time of extra jump when maintaining jump button
SHOOT_DELAY = 5		-- Delay between new bullets when holding shoot button

STARTPOSX = 1000	-- Initial player position on map
STARTPOSY = 210		-- Initial player position on map


PlayerClass =  Entity:new()

player = PlayerClass:new{

			x = STARTPOSX,
			y = STARTPOSY,
			h = 16,
			w = 11,

			img = {
				idle_r = newAnimation(love.graphics.newImage("assets/char/idle.png"), 22, 32, 0.1, 0),
				walk_r = newAnimation(love.graphics.newImage("assets/char/walk.png"), 22, 32, 0.1, 0),
				jump_r = newAnimation(love.graphics.newImage("assets/char/jump.png"), 22, 32, 0.1, 0),
				fall_r = newAnimation(love.graphics.newImage("assets/char/fall.png"), 22, 32, 0.1, 0),
				run_r  = newAnimation(love.graphics.newImage("assets/char/run.png"), 22, 32, 0.1, 0)},

			bullets = {},
			weapon = 1,
			ammo = 3,
			canShoot = true,
			shoot_timer = SHOOT_DELAY,

			pos_start = x,
			getstopped = false,
			x_vel = 0,
			y_vel = 0,

			jump_vel = JUMP_VERT,
			jump_timer = JUMP_TIME_MAX,
			speedX = WALK,
			angle = 0,

			state = "", -- will be used for animating char

			standing = false,
			bJumpLetGo = true, -- Allows the player to jump

			relativepos = 0,
			onslope = "false",

			directionX = "right",
			directionY = "none",

			life = 4
			} -- DEFINE AN INSTANCE OF THE CLASS PLAYER

player.img.run_r:setMode("loop")
player.img.walk_r:setMode("loop")
player.img.idle_r:setMode("loop")
player.img.jump_r:setMode("loop")
player.img.fall_r:setMode("loop")

function PlayerClass:restartlevel()
	player.life = 4
	player.x = STARTPOSX
	player.y = STARTPOSY
	player.bullet = {}
	player.x_vel = 0
	player.y_vel = 0
	player.isHit = false
end

function PlayerClass:jump(dt)
	if self.standing and self.bJumpLetGo then
		self.y_vel = self.jump_vel
		self.standing = false
		self.bJumpLetGo = false
	elseif self.jump_timer > 0 then	
		self.y_vel = self.jump_vel
		self.jump_timer = self.jump_timer - 1000*dt
	end
end

function PlayerClass:right(firsttime_move)
	if  firsttime_move == true  then 
			self.pos_start = self.x
	end		
	if self.x-self.pos_start < INIT_WALK then
			self.x_vel = self.speedX/2
	else
		self.x_vel = self.speedX
	end

	self.directionX = "right"
	self.getstopped = false
end

function PlayerClass:left(firsttime_move)
	if  firsttime_move == true  then 
			self.pos_start = self.x
	end			
	if self.pos_start-self.x < INIT_WALK then
			self.x_vel = -1*self.speedX/2
	else
		self.x_vel = -1*self.speedX
	end
	self.directionX = "left"
	self.getstopped = false
end

function PlayerClass:up()
	self.directionY = "up"
end

function PlayerClass:down()
	self.directionY = "down"
end

function PlayerClass:jumpLetGo()
	
	self.jump_timer = 0 
	if self.standing then
		self.bJumpLetGo = true
		self.jump_timer = JUMP_TIME_MAX
	end
end

function PlayerClass:stop()
	self.pos_start = self.x
	if not(self.isHit) then
		self.getstopped = true
	end
end


function checkCollideEnnemy(x,y,damage) -- Check point collision with ennemy. Damage enemy if there is a collision (for bullet)

	collision = false
	for i, ennemy in ipairs(ennemies) do
		if Point_Rectangle_CollisionCheck(x,y, ennemy.x,ennemy.y,ennemy.w,ennemy.h) == true then
			ennemy.health = ennemy.health - damage;
			if ennemy.health < 0 then
				table.remove(ennemies,i)
				score = score + 1
			end
			collision = true
		end
	end

	return collision
end

function PlayerClass:checkXcollisionsWithEnnemies(x_col)
	local collidingEnnemies = {}
	local ychecking_pos = {self.y-self.h/2+1, self.y+self.h/2-1}

	for i, ennemy in ipairs(ennemies) do
		for j = 1,2,1 do
			if Point_Rectangle_CollisionCheck(x_col,ychecking_pos[j], ennemy.x,ennemy.y,ennemy.w,ennemy.h) == true then
				table.insert(collidingEnnemies, ennemy)
			end
		end
	end

	return collidingEnnemies
end

function PlayerClass:checkYcollisionsWithEnnemies(y_col)
	local collidingEnnemies = {}
	local xchecking_pos = {self.x-self.w/2+1, self.x+self.w/2-1}

	for i, ennemy in ipairs(ennemies) do
		for j = 1,2,1 do
			if Point_Rectangle_CollisionCheck(xchecking_pos[j],y_col, ennemy.x,ennemy.y,ennemy.w,ennemy.h) == true then
				table.insert(collidingEnnemies, ennemy)
		collides = true
			end
		end
	end

	return collidingEnnemies
end

function PlayerClass:stepX( nextX ) 
	local x_col -- coordinate of the forward-facing edge
	if self.x_vel > 0 then -- facing right
		x_col = nextX + self.w/2
	elseif self.x_vel < 0 then  -- facing left
		x_col = nextX - self.w/2
	end
	local distX = self:stepXentity(nextX)
	local ennemies_local = self:checkXcollisionsWithEnnemies(x_col)

	for i, ennemy in ipairs(ennemies_local) do
		if self.x_vel > 0 then
			distX = ennemy.x-ennemy.w/2 - (self.x + self.w/2)
		else
			distX = ennemy.x+ennemy.w/2 - (self.x - self.w/2) 
		end
	end

	return distX
end

function PlayerClass:stepY( nextY )
	local y_col -- coordinate of the forward-facing edge

	if self.y_vel < 0 then -- facing up
		y_col = nextY - self.h/2
	else 				  -- facing down
		y_col = nextY + self.h/2
	end

	local  distY = self:stepYentity(nextY)

	local ennemies_local = self:checkYcollisionsWithEnnemies(y_col)

	for i, ennemy in ipairs(ennemies_local) do
		if self.y_vel > 0 then
			distY = ennemy.y-ennemy.h/2 - (self.y + self.h/2)
		else
			distY = ennemy.y+ennemy.h/2 - (self.y - self.h/2) 
		end
	end

	return distY
	
end


function PlayerClass:hit(  )
	if self.life > 0 then
		self.life = self.life-1
	end

	self.isHit = true
	self.y_vel = -250

	if not(self.x_vel == 0) then
		if self.directionX == "right" then
			self.x_vel = 75
		else	
			self.x_vel = -75
		end
	end
end

function PlayerClass:shoot(weapon) -- weapon type = 0 for bazooka, 1 for regular 

	if weapon == 0 and player.ammo > 0 then -- bazooka shooting
		player.ammo = player.ammo - 1
		camera.shaketype = "shooting"
		camera.shakedir = 0
		player.canShoot = false

		if self.directionX == "right" then
			bullet_u = 300 
		elseif self.directionX == "left" then	
			bullet_u = -300 
		else
			bullet_u = -300
		end

		if self.directionY == "up" then
			bullet_u = 0
			bullet_v = -550
		elseif self.directionY == "down" then
			bullet_u = 0
			bullet_v = 150
		else	
			bullet_v = -150
		end

		animBullet = newAnimation(love.graphics.newImage("assets/weapon/bullet.png"), 14, 14, 0.1, 0)
		animBullet:setMode("loop")
		newBullet = { x = player.x  - player.w/2, y = player.y-player.h, w=14,h=14,speedx = bullet_u , speedy = bullet_v, img = animBullet,  trailarray = {}, timer = 0.05, timerspawn = 1.5, timerlife = 4, spawn = true, type = weapon, damage = 5}
	
	elseif weapon == 1 then -- regular shooting
		camera.shaketype = "shooting"
		camera.shakedir = 0
		player.canShoot = false
		if self.directionX == "right" then
			bullet_u = 1000 
		else
			bullet_u = -1000
		end
		bullet_v = math.random(-60,60)
		--animBullet = newAnimation(love.graphics.newImage("assets/weapon/small_bullet.png"), 21, 14, 0.1, 0)
		animBullet = newAnimation(love.graphics.newImage("assets/weapon/bullet.png"), 14, 14, 0.1, 0)
		animBullet:setMode("loop")
		newBullet = { x = player.x + bullet_u/math.abs(bullet_u) * player.w/2 - 3*player.w/4, y = player.y - 5, w=21,h=14, speedx = bullet_u , speedy = bullet_v, img = animBullet,  trailarray = {}, timer = 0.05, timerspawn = 1.3, timerlife = 2, spawn = false, type = weapon, damage = 1}
	end

	table.insert(player.bullets, newBullet)
end

function PlayerClass:update(dt)

	if self.isHit then
		self.hit_timer = self.hit_timer - 100*dt
	end
	if self.hit_timer < 0 then
		self.isHit = false
		self.hit_timer = HIT_DELAY
	end

	if self.canShoot == false then
		self.shoot_timer = self.shoot_timer - 100*dt
	end
	if self.shoot_timer < 0 then
		self.canShoot = true
		self.shoot_timer = SHOOT_DELAY
	end
	-- Update bullets 
	-- trailarray : array of Trail object behind the bullet. Spawns new Trail every "timer" [s] after "timerspawn" [s]
	-- Bullet automatically disappears after collision or "timerlife" [s]

	for i, bullet in ipairs(self.bullets) do

		bullet.x = bullet.x + (bullet.speedx * dt)
		bullet.y = bullet.y + (bullet.speedy * dt)
		
		if bullet.type == 0 then -- gravity pull for bazooka bullets
			bullet.speedy = bullet.speedy + 600*dt
	    end
		
		bullet.timer = bullet.timer - dt 			-- Time between two trail spawn
		bullet.timerlife = bullet.timerlife - dt 	-- Time before erasing a trail
		bullet.timerspawn = bullet.timerspawn - dt  -- Time during which new trails are spawn
		bullet.img:update(dt)

		if (bullet.timer < 0 and bullet.spawn == true )then -- Spawn trail behind bullet
			animWolk = newAnimation(love.graphics.newImage("assets/weapon/wolk.png"), bullet.w, bullet.h, 0.025, 0)
			animWolk:setMode("once")
			newTrail = { x = bullet.x+bullet.w/2, y = bullet.y+bullet.h/2, angle = math.random(0,365), img = animWolk, timer = 0.5}
			table.insert(bullet.trailarray, 1, newTrail)
			bullet.timer = 0.0075+0.0015*math.random(-10, 10)
		end	

		for j, trail in ipairs(bullet.trailarray) do -- Update trail behind bullet
			trail.timer = trail.timer - dt
			trail.img:update(dt)
			if trail.timer < 0 then
				table.remove(bullet.trailarray,j)
			end
		end

		if bullet.timerspawn < 0 then	-- Stop spawning trail behind bullet
			bullet.spawn = false
		end

		if bullet.timerspawn > 0 and ( checkCollide(bullet.x,bullet.y) or checkCollideEnnemy(bullet.x,bullet.y, bullet.damage) ) then -- Check collision with ground or ennemy
			bullet.timerspawn = 0

			if bullet.type == 0 then 	-- Spawn explosion
				animImg = newAnimation(love.graphics.newImage("assets/weapon/explosion2.png"), 67, 67, 0.1, 0)
				animImg:setMode("once")
				table.insert(anims,{ x = bullet.x - 1.5*20, y = bullet.y - 1.5*20, animation = animImg, scale = 1})
				FX_whiteflicker()
				
				if camera.shake then
					camera.shakeVal = 0
				end
				camera.shaketype = "explosion"
				camera.shakedir = math.atan(bullet.speedy/bullet.speedx)
			end
		end
		if bullet.timerlife < 0 then  
			table.remove(self.bullets,i)
		end
		-- if bullet.x > window_width then -- remove bullets when they pass off the screen
		-- 	table.remove(self.bullets, i)
		-- end
	end

	if player.state == "right" or player.state == "left" then
		player.img.run_r:update(dt)
		player.img.walk_r:update(dt)
	elseif player.state == "jump" then
		player.img.jump_r:update(dt)
	elseif player.state == "fall" then
		player.img.fall_r:update(dt)
	else
		player.img.idle_r:update(dt)
	end

	if player.standing == true then 
		player.angle = 0
	end	

	self:checkifOnslope()
	self.state = self:getState()

	self.y_vel = self.y_vel + (world.gravity * dt)
	self.y_vel = math.min(self.y_vel,MAX_YSPEED)

	local nextY = self.y + (self.y_vel*dt)
	local nextX = self.x + (self.x_vel*dt)
	
	if not(self.x_vel == 0) then
		self.x = self.x + self:stepX(nextX)
	end

	self.relativepos = self.x % 16
	self.y = self.y + self:stepY(nextY)

	if not(self:checkSpikecollisions(nextX, nextY )[1] == nil) and not(self.isHit) then
		self:hit()
	end

	if not(self:checkAmmocollisions(nextX, nextY )[1] == nil)  then
		self.ammo = self.ammo + 1
	end

	if self.getstopped == true then
		if self.x_vel > 0 then
			self.x_vel = self.x_vel - END_RUN_DAMP*dt
		elseif self.x_vel < 0 then
			self.x_vel = self.x_vel + END_RUN_DAMP*dt
		end

		if (self.directionX == "left"and self.x_vel > 0) or (self.directionX == "right"and self.x_vel < 0) then
			self.x_vel = 0
			self.getstopped = false
		end
	end



end

function  PlayerClass:draw( )

	-- Player Hitbox
	if debug == true then
		love.graphics.setColor(255,0,0)
		love.graphics.rectangle("fill", player.x - player.w/2, player.y - player.h/2, player.w, player.h)
		love.graphics.setColor(255,255,255)
	end
	
	for i, bullet in ipairs(self.bullets) do
		if bullet.timerspawn > 0 then
			if bullet.bulletype == 1 then
				bullet.img:draw(bullet.x-bullet.w/2, bullet.y-bullet.h/2, math.atan(bullet.speedy/bullet.speedx))
				if debug == true then
					love.graphics.setColor(255,0,0)
					love.graphics.rectangle("fill", bullet.x-1, bullet.y -1, 2, 2)
					love.graphics.setColor(255,255,255)
				end
			else
				bullet.img:draw(bullet.x-bullet.w/2, bullet.y-bullet.h/2, 0)
				if debug == true then
					love.graphics.setColor(255,0,0)
					love.graphics.rectangle("fill", bullet.x-1, bullet.y -1, 2, 2)
					love.graphics.setColor(255,255,255)
				end
			end
			
		end
		for j, trail in ipairs(bullet.trailarray) do
			trail.img:draw(trail.x, trail.y, 0, 1, 1, bullet.w, bullet.h) 
			--love.graphics.draw(trail.img, trail.x, trail.y, trail.angle, 1, 1, 14, 14)
		end
	end

	if (player.hit_timer%2 < 0.5) then
		if player.state == "right" then
			if not(player.x_vel == player.speedX) then
				player.img.walk_r:draw(player.x - player.w,player.y-player.h-3)
			else
				player.img.run_r:draw(player.x - player.w,player.y-player.h-3)
			end
		elseif player.state == "left" then
			if not(player.x_vel == -1*player.speedX) then
				player.img.walk_r:draw(player.x + player.w,player.y-player.h-3,0,-1,1)
			else
				player.img.run_r:draw(player.x + player.w,player.y-player.h-3,0,-1,1)
			end
		elseif player.state == "jump" then
			if player.directionX == "right" then
				player.img.jump_r:draw(player.x - player.w,player.y-player.h-3)
			else
				player.img.jump_r:draw(player.x + player.w,player.y-player.h-3,0,-1,1)
			end
		elseif player.state == "fall" then
			if player.directionX == "right" then
				player.img.fall_r:draw(player.x - player.w,player.y-player.h-3)
			else
				player.img.fall_r:draw(player.x + player.w,player.y-player.h-3,0,-1,1)
			end
		else
			if player.directionX == "right" then
				player.img.idle_r:draw( player.x - player.w ,player.y-player.h-3,0,1,1)
			else
				player.img.idle_r:draw(player.x + player.w ,player.y-player.h-3,0,-1,1)
			end
		end
	end
end

