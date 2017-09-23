isPressedesc = false -- checks if escape is pressed
isPressedm = false -- checks if m is pressed 
isPressedr = false -- checks if m is pressed 
isPressedright = false -- checks if m is pressed 
isPressedleft = false -- checks if m is pressed 
function keyboardControls(dt)

	--player controls for moving left or right
	if love.keyboard.isDown("left") then

		player:left(not(isPressedleft))		
		if  isPressedleft == false  then 
			isPressedleft = true

		end
	else
		isPressedleft = false
	end	
	
	if love.keyboard.isDown("right") then

		player:right(not(isPressedright))		
		if  isPressedright == false  then 
			isPressedright = true

		end
	else
		isPressedright = false
	end		

	if (not(love.keyboard.isDown("right")) and not(love.keyboard.isDown("left"))) then
		player:stop()
	end
	
	if love.keyboard.isDown("up") then
		player:up()
	elseif love.keyboard.isDown("down") then
		player:down()
	else
		player.directionY = "none"	
	end
	
	-- Main action button
	if love.keyboard.isDown("e") then
		if GAMESCREEN == "menu" then
			GAMESCREEN = "play"
		elseif GAMESCREEN == "pause" then
			GAMESCREEN = "play"
		elseif GAMESCREEN == "death" then
			restartLevel()
		elseif GAMESCREEN == "play" then
			if (player.canShoot) then
				player:shoot(1)
			end
		end
	end 

		if love.keyboard.isDown("r")  then
	-- 	if  isPressedr == false  then 
	-- 		isPressedr = true

	-- 		if player.weapon == 0 then
	-- 			player.weapon = 1
	-- 		else
	-- 			player.weapon = 0
	-- 		end	
	-- 	end
	-- else
	-- 	isPressedr = false

		if GAMESCREEN == "menu" then
			GAMESCREEN = "play"
		elseif GAMESCREEN == "pause" then
			GAMESCREEN = "play"
		elseif GAMESCREEN == "death" then
			restartLevel()
		elseif GAMESCREEN == "play" then
			if (player.canShoot) then
				player:shoot(0)
			end
		end
	end	

	--player controls for jumping
	if love.keyboard.isDown("lshift") or love.keyboard.isDown("space") or love.keyboard.isDown("up") then
		player:jump(dt)
	else
		player:jumpLetGo()
	end


	--camera actions
	-- if love.keyboard.isDown("o") then
	-- 	camera:scale(0.99,0.99)
	-- elseif love.keyboard.isDown("p") then
	-- 	camera:scale(1.01,1.01)
	-- elseif love.keyboard.isDown("l") then
	-- 	camera:rotate(dt)
	-- elseif love.keyboard.isDown("m") then
	-- 	camera:rotate(-dt)		
	-- elseif love.keyboard.isDown(":") then
	-- 	camera:reset()
	-- end

	if love.keyboard.isDown("m") then

		if  isPressedm == false  then 
			isPressedm = true

			if music:getVolume() == 0 then
				resumeSounds()
			else
				muteSounds()
			end	
		end
	else
		isPressedm = false
	end	

	-- toggle slowmode
	if love.keyboard.isDown("a") then
		slowmode = true
	elseif love.keyboard.isDown("s") then
		slowmode = false	
	end

	-- toggle debug text messages
	if love.keyboard.isDown("q") then
		debug = true
	elseif love.keyboard.isDown("w") then
		debug = false	
	end

	-- spawn ennemies
	if love.keyboard.isDown("z") then
		SummonEnnemies(player.x ,player.y-200,1)
	end



	-- display message
	if love.keyboard.isDown("x") then
		addBigMessage("First Cave",40)
	end

	--close window
	if love.keyboard.isDown("escape") then
		if  isPressedesc == false  then 
			isPressedesc = true

			if GAMESCREEN == "menu" then
				love.event.quit()
			elseif GAMESCREEN == "pause" then
				love.event.quit()
			elseif GAMESCREEN == "death" then
				love.event.quit()
			elseif GAMESCREEN == "play" then
				GAMESCREEN = "pause"
			end
		end
	else
		isPressedesc = false
	end



end

