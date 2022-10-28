extends KinematicBody2D

var pos = 0
var facing = 1

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
