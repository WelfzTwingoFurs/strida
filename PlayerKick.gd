extends KinematicBody2D

var pos = 0
var facing = 1
var pierce = false

var extra_position = Vector2(0,0)
var extra_motion = Vector2(0,0)

func _ready():
	$Sprite.scale.x = facing
	
	if pos == -1:
		$AniPlay.play("high")
	elif pos == 0:
		$AniPlay.play("mid")
	elif pos == 1:
		$AniPlay.play("low")
	

var motion = Vector2(0,0)

func _physics_process(_delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	extra_position += extra_motion
	
	position = Global.player.position + extra_position
	
#	if Engine.get_frames_drawn() % 2 == 0:
#		self.modulate.a = 0
#	else:
#		self.modulate.a = 1


func _on_Area_body_entered(body):
	if body.is_in_group("freezeful"):
		body.freeze()
		if !pierce:
			queue_free()
		else:
			pass
