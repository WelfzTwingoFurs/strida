extends Camera2D

func _ready():
	Global.camera = self

func _process(_delta):
	if Input.is_action_pressed("ctrl"):
		if Input.is_action_pressed("cam_minus"):
			#if zoom.x < 1:
			zoom += Vector2(0.01,0.01)
		elif Input.is_action_pressed("cam_plus"):
			zoom -= Vector2(0.01,0.01)
		
		
	else:
		if Input.is_action_just_pressed("cam_minus"):
			if zoom.x != 1:
				zoom *= 2
		elif Input.is_action_just_pressed("cam_plus"):
			zoom /= 2
