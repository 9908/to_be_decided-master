
anims = {}	 -- array of anims
bgs = {} 	 -- array of moving backgrounds
whiteflicker = false
whiteflicker_timer = 0
nightbgwidth = 640

function loadArt()
	tree1 = love.graphics.newImage('assets/lvl1/tree1.png')
	tree2 = love.graphics.newImage('assets/lvl1/tree2.png')
	mountain = love.graphics.newImage('assets/lvl1/mountain.png')
	bg1 = love.graphics.newImage('assets/lvl1/bg1.png')
	apple = love.graphics.newImage('assets/lvl1/apple.png')
	cloud1 = love.graphics.newImage('assets/lvl1/cloud1.png')
	cloud2 = love.graphics.newImage('assets/lvl1/cloud2.png')
	UI = love.graphics.newImage('assets/UI.png')

	cloud1 = {x1 = 0, x2 = 200, y = 64, speed = 30, img = love.graphics.newImage('assets/lvl1/cloud1.png'), width = 0}
	cloud2 = {x1 = 0, x2 = 200, y = 53, speed = 45, img = love.graphics.newImage('assets/lvl1/cloud2.png'), width = 0}
	nightbg1  = {x1 = 0, x2 = 2*nightbgwidth, y= 30-50, speed = 30, img = love.graphics.newImage('assets/lvl1/nightbg1.png'), width = 2*nightbgwidth }
	nightbg2  = {x1 = 0, x2 = 2*nightbgwidth, y= 20-50, speed = 40, img = love.graphics.newImage('assets/lvl1/nightbg2.png'), width = 2*nightbgwidth }
	nightbg3  = {x1 = 0, x2 = 2*nightbgwidth, y= 10-50, speed = 50, img = love.graphics.newImage('assets/lvl1/nightbg3.png'), width = 2*nightbgwidth }
	nightbg4  = {x1 = 0, x2 = 2*nightbgwidth, y= 00-50, speed = 60, img = love.graphics.newImage('assets/lvl1/nightbg4.png'), width = 2*nightbgwidth }

	--table.insert(bgs, cloud1) -- TODO modify cloud
	--table.insert(bgs, cloud2)
	table.insert(bgs, nightbg4)
	table.insert(bgs, nightbg3)
	table.insert(bgs, nightbg2)
	table.insert(bgs, nightbg1)

end

function loadSound()
	--music = love.audio.newSource("assets/sounds/Maxime Dangles - Plane (Original Mix).mp3") 
	music = love.audio.newSource("assets/sounds/Nathan Fake The Sky Was Pink Holden Remix.mp3")
	music:setLooping(true)                            -- all instances will be looping
	music:play()
	
	jump_SFX = love.audio.newSource("assets/sounds/jump.wav", "static")
	hit_SFX = love.audio.newSource("assets/sounds/hit.wav", "static")
	shoot_SFX = love.audio.newSource("assets/sounds/shoot.wav", "static")
	xplosion_SFX = love.audio.newSource("assets/sounds/xplosion.wav", "static")
	hitsheep_SFX = love.audio.newSource("assets/sounds/rdm8.wav", "static")
	coin_SFX = love.audio.newSource("assets/sounds/coin.wav", "static")

	muteSounds()
end

function muteSounds()
	music:setVolume(0)	
	coin_SFX:setVolume(0)
	hitsheep_SFX:setVolume(0)
	xplosion_SFX:setVolume(0)
	shoot_SFX:setVolume(0)
	hit_SFX:setVolume(0)
	jump_SFX:setVolume(0)	
end

function resumeSounds()
    music:setVolume(1)	
	coin_SFX:setVolume(0.3)
	hitsheep_SFX:setVolume(0.3)
	xplosion_SFX:setVolume(0.3)
	shoot_SFX:setVolume(0.4)
	hit_SFX:setVolume(0.4)
	jump_SFX:setVolume(0.3)	
end

function FX_whiteflicker() -- Flashes white the screen
	whiteflicker = true
	whiteflicker_timer = 0.066 -- duration of white screen
end

function updateFX(dt) 

	-- Update animations
	for i, anim in ipairs(anims) do
		anim.animation:update(dt) 
		if anim.animation:getCurrentFrame() == anim.animation:getSize() then
			table.remove(anims,i)
		end
	end

	-- Update flicker
	if whiteflicker_timer < 0 then
		whiteflicker = false
	else
		whiteflicker_timer = whiteflicker_timer - dt
	end

	-- Update the backgrounds
	for i, bg in ipairs(bgs) do
		bg.x1 = bg.x1 - (bg.speed)*dt
		bg.x2 = bg.x2 - (bg.speed)*dt
		if(bg.x1 + bg.width < 0) then
			bg.x1 = bg.x2 + bg.width
		elseif (bg.x2 + bg.width < 0) then
			bg.x2 = bg.x1 + bg.width
		end
		--if bg.x1 < -250 then
		--	bg.x1 = screenWidth
		--end
	end

	-- if x1 < -250 then
	-- 	x1 = screenWidth
	-- end
	-- if x2 < -250 then
	-- 	x2 = screenWidth
	-- end
end

function drawFX()

	-- Draw Animations
	for i, anim in ipairs(anims) do
		anim.animation:draw(anim.x,anim.y,0,anim.scaleX,anim.scaleX,0,0)
	end

	-- Draw flicker
	if whiteflicker then
		love.graphics.setColor(255,255,255,160)
		love.graphics.rectangle("fill", camera.x, camera.y, screenWidth, screenHeight)
		love.graphics.setColor(255,255,255)
	end
end

function  drawArt( )
		-- map1. (1,1)

		for i, bg in ipairs(bgs) do
			love.graphics.draw(bg.img,bg.x1,bg.y)
			love.graphics.draw(bg.img,bg.x2,bg.y)
		end

		love.graphics.draw(mountain,218+screenWidth/2,66)
		love.graphics.draw(bg1,0+screenWidth/2,175)
		love.graphics.draw(tree1,69+screenWidth/2,130)
		love.graphics.draw(tree2,screenWidth/2,134)
		love.graphics.draw(apple,105+screenWidth/2,156)
		love.graphics.draw(apple,88+screenWidth/2,148)
		love.graphics.draw(apple,74+screenWidth/2,167)
		love.graphics.draw(apple,50+screenWidth/2,147)

end
