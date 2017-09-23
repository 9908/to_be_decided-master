
require("ennemy")
wave = 0 							-- Current wave numbering
start_new_wave = true
TIME_START_WAVE = 3 				-- Time between message display and ennemy spawn

timerStart = love.timer.getTime() 	


function updateWave(dt) -- Update the wave system
	if table.getn(ennemies) == 0 and start_new_wave then
		start_new_wave = false
		wave = wave + 1
		addBigMessage("Wave no."..wave,40)
		timerStart = love.timer.getTime() 
	end
		
	if love.timer.getTime() - timerStart > TIME_START_WAVE and start_new_wave == false then
		SummonEnnemies(1000,195,wave*5)
		start_new_wave = true
	end
end
