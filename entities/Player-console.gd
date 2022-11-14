extends Label

export var type = 0
export var mode = 0

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
			margin_top    = (-OS.window_size.y/2 * 1/Global.zoom)
			margin_left   = (-OS.window_size.x/2 * 1/Global.zoom)
			margin_bottom = margin_top + 10
			margin_right = margin_left + 10
			
			if Input.is_action_just_pressed("con_mode"):
				mode += 1
				if mode > 2:
					mode = 0
			
			if mode == 0:
				text = str("[F1] for help")
			elif mode == 1:
				text = str("CONTROLS:\n move-WASD,\n jump-UP,\n kick-RIGHT.\n next page-F1")
			elif mode == 2:
				text = str("DEBUG:\n noclip&heal-C,\n resolution readjust-0,\n ")
