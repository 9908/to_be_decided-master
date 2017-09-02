local AdvTiledLoader = require("AdvTiledLoader.Loader")

-- Includes
require("camera")
require("AnAL") 
require("player")
require("text")
require("utilities")
require("FX")
require("ennemy")
require("entity")
require("waves")

-- Global variables
slowmode = false
debug = false
score = 0 -- number of ennemy killed

currentscreenX = 0
currentscreenY = 0
screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()

GAMESCREEN = "menu" -- play - pause - start menu - deathscreen - cutscenes - etc - ...

function love.load() -- Initial loads

	love.graphics.setBackgroundColor( 87 , 137 , 156 )

	-- Load map
	AdvTiledLoader.path = "maps/"
	map = AdvTiledLoader.load("level_1.tmx") 

	-- Set initial camera location
	camera:setBounds(0, 0, map.width * map.tileWidth - screenWidth/2, map.height * map.tileHeight - screenHeight/2)

	-- Global world variables
	world =		{
				gravity = 1100
				}
	

	loadArt()
	loadSound()


	--collectgarbage("stop") -- ??? CAUSE FOR THE FPS LOSSES ???

	min_dt = 1/60
    next_time = love.timer.getTime()
	
end

function love.draw() -- Draw at each iteration

	if GAMESCREEN == "play" then


	-- Set camera position
	camera:set(0,0)

	-- Draw map elements behind player
	map:drawBackground()

	-- Draw still art
	drawArt()

	-- Draw map elements before player
	map:drawForeground()

	-- Draw Player
	player:draw()

	-- Draw Ennemies
	drawEnnemies()
	
	-- Draw FX
	drawFX()

	-- Pops the current coordinate transformation from the transformation stack. ( 0,0 is again the top-left coordinate)
	camera:unset()
	
	-- Use new font and draw additional messages
	drawMessages()
	

	-- Draw UI
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("fill", 2*18,2*32,2*13*player.life,2*6) -- draw life bar
	for i = 1,player.ammo do
		love.graphics.rectangle("fill", 2*18+i*18,32,6,12) -- draw ammunitions
	end
	love.graphics.setColor(255,255,255)

	love.graphics.draw(UI,12,20,0,2,2)
	useCustomFont(40)
	love.graphics.printf("Kills "..score, 0, 0.08*love.graphics.getHeight(), 0.12*love.graphics.getWidth(),"center") -- Display Score


	-- Use default font and draw debug messages
	drawDebug()

	local cur_time = love.timer.getTime()
    if next_time <= cur_time then
     	next_time = cur_time
     	return
   	end
   	love.timer.sleep(next_time - cur_time) -- Fixed a cap of FPS at 60

   	-- Je pense que le problème vient de l'algorithme même du jeu.
   	-- Relire le code ! et optimiser tt ça
   	-- https://love2d.org/wiki/Category:Tutorials
   	-- https://love2d.org/wiki/Tutorial:Efficient_Tile-based_Scrolling

   	-- https://www.google.be/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=computational%20efficiency%20love2d

   	elseif GAMESCREEN == "menu" then
		useDefaultFont()
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill", 0,0,screenWidth,screenHeight)
		love.graphics.setColor(255,255,255)
		love.graphics.print("Main Title",screenWidth*0.4,screenHeight/3,0,2,2)
		love.graphics.print("Press 'e' to start Game", screenWidth*0.4,screenHeight/2)
   	elseif GAMESCREEN == "pause" then
		useDefaultFont()
		love.graphics.setColor(125,6,45)
		love.graphics.rectangle("fill", 0,0,screenWidth,screenHeight)
		love.graphics.setColor(255,255,255)
		love.graphics.print("Pause Menu",screenWidth*0.4,screenHeight*0.2,0,2,2)
		love.graphics.print("Press 'escape' to quit Game", screenWidth*0.4,screenHeight*0.4)
		love.graphics.print("Press 'e' to resume Game", screenWidth*0.4,screenHeight*0.45)
		love.graphics.print("Press 'm' to mute/resume Music", screenWidth*0.4,screenHeight*0.6)
		love.graphics.print("Press 'q/s' to Enable debug mode", screenWidth*0.4,screenHeight*0.65)
		love.graphics.print("Press 'a/z' for Slowmode", screenWidth*0.4,screenHeight*0.7)
		love.graphics.print("Press 'x' for Level title", screenWidth*0.4,screenHeight*0.75)
		love.graphics.print("Press 'r' To switch weapon", screenWidth*0.4,screenHeight*0.8)
		love.graphics.print("Press 'w' To spawn ennemies", screenWidth*0.4,screenHeight*0.85)
	elseif GAMESCREEN == "death" then
		useDefaultFont()
		love.graphics.setColor(255,0,0)
		love.graphics.rectangle("fill", 0,0,screenWidth,screenHeight)
		love.graphics.setColor(0,0,0)
		love.graphics.print("You Died",screenWidth*0.4,screenHeight/3,0,2,2)
		love.graphics.print("Press 'e' to try again", screenWidth*0.4,screenHeight/2)	
   	end

end

function love.update(dt) -- Update at each iteration. dt : Time since the last update in seconds.

	-- Check keyboard inputs
	keyboardControls(dt)

	if GAMESCREEN == "play" then
		if not(music:isPlaying()) then
			music:play()
			music:setVolume(0)
		end

	updateWave(dt)


    if player.life == 0 then
    	GAMESCREEN = "death"
    end

    next_time = next_time + min_dt

	if slowmode == true then
		dt = dt / 10
	end	

	--Update the tile range of drawn tiles
	map:setDrawRange(camera.x,camera.y,screenWidth/2,screenHeight/2)
	map:_updateTileRange()

	-- Update messages
	updateMessages(dt)

	-- Update FX
	updateFX(dt) 

	-- Update player
	player:update(dt)

	-- Update Ennemies
	updateEnnemies(dt)

	-- Update camera position
	camera:update(dt,player.directionX, player.directionY)
	--camera:setPosition( player.x - (screenWidth/2), player.y - (screenHeight/2))
	camera:setPosition( player.x , player.y )


   	elseif GAMESCREEN == "menu" then
   	elseif GAMESCREEN == "pause" then
   	end
	
end

function drawDebug() -- Draws debug messages
	if debug then 
		useDefaultFont()
		local fps = tostring(love.timer.getFPS())
		love.graphics.setColor(0,0,0)
		love.graphics.print("Current FPS: "..fps, 9, 10)
		love.graphics.print("Current Memory Usage (kB): "..tostring(collectgarbage("count")), 9, 10+1*15)
		love.graphics.print("slowmode: "..tostring(slowmode), 9, 10+2*15)
		
		love.graphics.print("playerX: "..player.x, 459, 10)
		love.graphics.print("playerY: "..player.y, 459, 10+1*15)

		love.graphics.print("camera_x2 bounds: "..camera._bounds.x2,459,10+2*15)
		love.graphics.print("graphics_width: "..screenWidth,459,10+3*15)
		love.graphics.print("camera x: "..camera.x,459,10+4*15)
		love.graphics.print("camera y: "..camera.y,459,10+5*15)
		love.graphics.print("currentscreen x: "..currentscreenX,459,10+6*15)
		love.graphics.print("currentscreen y: "..currentscreenY,459,10+7*15)

		-- love.graphics.print("relative pos: "..player.relativepos, 459, 10+2*15)
		 love.graphics.print("player state: "..player.state, 459, 10+16*15)
		 love.graphics.print("player xvel: "..player.x_vel, 459, 10+13*15)
		 love.graphics.print("player getstopped: "..tostring(player.getstopped), 459, 10+14*15)
		 love.graphics.print("player yvel: "..player.y_vel, 459, 10+15*15)
		love.graphics.print("player standing: "..tostring(player.standing), 459, 10+8*15)
		love.graphics.print("player isHit: "..tostring(player.isHit), 459, 10+9*15)
		-- love.graphics.print("player onslope: "..tostring(player.onslope), 459, 10+7*15)
		love.graphics.print("player directionX: "..player.directionX, 459, 10+10*15)
		-- love.graphics.print("player directionY: "..player.directionY, 459, 10+9*15)
		-- love.graphics.print("player angle: "..player.angle, 459, 10+10*15)
		
		local Count = 0

		for Index, Value in pairs( anims ) do
	  		Count = Count + 1
		end

		love.graphics.print("# anims: "..Count, 459, 10+11*15)
		love.graphics.print("whiteflicker "..tostring(whiteflicker), 459, 10+12*15)

		love.graphics.setColor(255,255,255)
	end
end
