extends Label

export var type = 0

func _ready():
	visible = true

func _process(_delta):
	if Input.is_action_just_pressed("bug_console"):
		visible = !visible
	
	if visible:
		if type == 0:
			margin_top    = (OS.window_size.y/3 * 1/Global.zoom)
			margin_left   = (OS.window_size.x/3 * 1/Global.zoom)
			margin_bottom = margin_top + 10
			margin_right = margin_left + 10
			text = str(int(abs(Global.player.motion.x)))
		
		elif type == 1:
			margin_top    = (OS.window_size.y/3 * 1/Global.zoom)
			margin_left   = (-OS.window_size.x/3 * 1/Global.zoom) - 25
			margin_bottom = margin_top + 10
			margin_right = margin_left + 10
			text = str(Global.player.HP)
	
		elif type == 2:
			margin_top    = (OS.window_size.y/4.3 * 1/Global.zoom)
			margin_left   = (-OS.window_size.x/3 * 1/Global.zoom)
			margin_bottom = margin_top + 10
			margin_right = margin_left + 10
