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
	t.window.height = 19*48 	
	t.window.width = 25*48
end