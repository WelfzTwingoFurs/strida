extends Sprite

func _ready():
	material = material.duplicate()


export var timer = Vector2(0.0,0.0)

func _process(_delta):
	#self.modulate.a = 0 if Engine.get_frames_drawn() % 2 == 0 else 1.0
	material.set_shader_param("timer", timer)
	
	$Label.text = str(timer)
	
	if !Input.is_action_pressed("ctrl"):
		if Input.is_action_pressed("ply_up"):
			timer.x += 0.01
		
		elif Input.is_action_pressed("ply_down"):
			timer.x -= 0.01
	
	else:
		if Input.is_action_pressed("ply_up"):
			timer.y += 0.01
		
		elif Input.is_action_pressed("ply_down"):
			timer.y -= 0.01
