-- Diplay message on screen

messages = {}

function useCustomFont(size)
	font = love.graphics.newFont("assets/Minusio.ttf", size)
	love.graphics.setFont(font)
end

function useDefaultFont()
	love.graphics.setFont(love.graphics.newFont(12))
end

function updateMessages( dt ) 
	for i, msg in ipairs(messages) do

		if msg.toremove == true then
			if msg.opacity > 0 then
				msg.opacity = msg.opacity - msg.fadeawayspeed*dt
			else
				table.remove(messages, i)
			end
		else
			if msg.opacity < msg.maxopacity then -- Max opacity reached
				msg.opacity = msg.opacity + msg.fadeawayspeed*dt
			else
				if love.timer.getTime() - msg.timerStart >= msg.timetodisplay then -- stop displaying
					msg.toremove = true
				end
			end
		end
	end
end

function addBigMessage(textmsg, sizemsg)
	table.insert(messages, 
		{ 
			text = textmsg,
			opacity = 0,
			fadeawayspeed = 250,
			timetodisplay = 3,
			timerStart = love.timer.getTime(), -- Starts too soon ?
			size = sizemsg,
			toremove = false,
			maxopacity = 225,
		}
	)
end

function drawMessages()
	useCustomFont(40)
	for i, msg in ipairs(messages) do
		--myColor = {155, 155, 70,msg.opacity}
		love.graphics.setColor(52,58,71)
		love.graphics.rectangle("fill", 0, 0,love.graphics.getWidth(), 0.12*love.graphics.getHeight()+msg.opacity-msg.maxopacity)
		love.graphics.rectangle("fill", 0, 0.88*love.graphics.getHeight()-msg.opacity+msg.maxopacity,love.graphics.getWidth(), love.graphics.getHeight())

		myColor = {255, 255, 255,255}
		love.graphics.setColor(myColor)
		if msg.opacity > 0.9*msg.maxopacity then
		love.graphics.printf(msg.text, 0, 0.92	*love.graphics.getHeight(), love.graphics.getWidth(),"center")
		end
	end
end

function drawScore()
	love.graphics.print(score, 50 , 40)
end

