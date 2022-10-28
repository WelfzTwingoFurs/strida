extends Label

var change_checker = Vector2(0,0)

func _ready():
	visible = true
#	margin_right = 99999
#	margin_bottom = 99999

func _process(_delta):
	if Input.is_action_just_pressed("bug_console"):
		visible = !visible
	
	if Input.is_action_just_pressed("cam_plus") or Input.is_action_just_pressed("cam_minus") or change_checker != OS.window_size:
		margin_top    = (-OS.window_size.y * 1/Global.zoom)
		margin_left   = (-OS.window_size.x * 1/Global.zoom)
		
		#margin_bottom = (OS.window_size.y * Global.camera.zoom.y)
		#margin_right = (OS.window_size.x * Global.camera.zoom.x)
	
	text = str(int(Global.player.motion.x))
	
