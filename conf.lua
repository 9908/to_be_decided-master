function love.conf(t)
	t.modules.joystick = true
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.image = true
	t.modules.graphics = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true
	t.modules.thread = true
	t.modules.physics = true
	t.console = true
	t.title = "My Project"
	t.author = "Suladan"
	t.window.fullscreen = false
	t.window.vsync = true
	t.window.fsaa = 0
	t.window.height = 19*16*3 	-- Works for x2 and x3 but not x1. Some elements like enemy spawn are modified by this value
	t.window.width = 25*16*3		
end