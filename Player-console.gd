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
		margin_top    = (OS.window_size.y/3 * 1/Global.zoom)
		margin_left   = (OS.window_size.x/3 * 1/Global.zoom)
		
		margin_bottom = margin_top + 10
		margin_right = margin_left + 10
	
	text = str(int(abs(Global.player.motion.x)))
	
