extends Label


func _ready():
	visible = true

func _process(_delta):
	if Input.is_action_just_pressed("bug_console"):
		visible = !visible
	
