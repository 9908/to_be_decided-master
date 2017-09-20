
anims = {}
whiteflicker = false
whiteflicker_timer = 0
x1 = 0
x2 = 0
function loadArt()
	tree1 = love.graphics.newImage('assets/lvl1/tree1.png')
	tree2 = love.graphics.newImage('assets/lvl1/tree2.png')
	mountain = love.graphics.newImage('assets/lvl1/mountain.png')
	bg1 = love.graphics.newImage('assets/lvl1/bg1.png')
	apple = love.graphics.newImage('assets/lvl1/apple.png')
	cloud1 = love.graphics.newImage('assets/lvl1/cloud1.png')
	cloud2 = love.graphics.newImage('assets/lvl1/cloud2.png')

	UI = love.graphics.newImage('assets/UI.png')
end

function loadSound()
	--music = love.audio.newSource("assets/sounds/Maxime Dangles - Plane (Original Mix).mp3") 
	music = love.audio.newSource("assets/sounds/Nathan Fake The Sky Was Pink Holden Remix.mp3")
	music:setLooping(true)                            -- all instances will be looping
    --music:setVolume(1)	

			music:play()
	jump_SFX = love.audio.newSource("assets/sounds/jump.wav", "static")
	hit_SFX = love.audio.newSource("assets/sounds/hit.wav", "static")
	shoot_SFX = love.audio.newSource("assets/sounds/shoot.wav", "static")
	xplosion_SFX = love.audio.newSource("assets/sounds/xplosion.wav", "static")
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
	x1 = x1-20*dt
	x2 = x2-13*dt
	if 23+x1 < 0-250 then
		x1 = screenWidth/2
	end
	if 217+x2 < 0-250 then
		x2 = screenWidth/2
	end
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
		local screenWidth = screenWidth/2
		local screenHeight = screenHeight/2
		
		if currentscreenX == 1 and currentscreenY == 0 then 
			love.graphics.draw(cloud1,23+x1+currentscreenX*screenWidth,currentscreenY*screenHeight+64)
			love.graphics.draw(cloud2,217+x2+currentscreenX*screenWidth,currentscreenY*screenHeight+53)
			love.graphics.draw(mountain,218+currentscreenX*screenWidth,currentscreenY*screenHeight+66)
			love.graphics.draw(bg1,0+currentscreenX*screenWidth,currentscreenY*screenHeight+175)
			love.graphics.draw(tree1,69+currentscreenX*screenWidth,currentscreenY*screenHeight+130)
			love.graphics.draw(tree2,331+currentscreenX*screenWidth,currentscreenY*screenHeight+134)
			love.graphics.draw(apple,105+currentscreenX*screenWidth,currentscreenY*screenHeight+156)
			love.graphics.draw(apple,88+currentscreenX*screenWidth,currentscreenY*screenHeight+148)
			love.graphics.draw(apple,74+currentscreenX*screenWidth,currentscreenY*screenHeight+167)
			love.graphics.draw(apple,350+currentscreenX*screenWidth,currentscreenY*screenHeight+147)
		end
end
