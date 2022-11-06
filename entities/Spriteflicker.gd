extends Sprite

func _process(_delta):
	modulate.a = 0 if Engine.get_frames_drawn() % 2 == 0 else 1
