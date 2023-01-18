extends KinematicBody2D

var pos = 0
var facing = 1
var pierce = false
var wavetime = 1
var freezetime = 1

var extra_position = Vector2(0,0)
var extra_motion = Vector2(0,0)

func _ready():
	$Sprite.scale.x = facing
	
	
	$AniPlay.playback_speed = wavetime
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
	

func _process(_delta):
	$Sprite.modulate.a = 0 if Engine.get_frames_drawn() % 2 == 0 else 1
	
	#if !pierce && (is_on_floor() or is_on_ceiling() or is_on_wall()):
	#	queue_free()


func _on_Area_body_entered(body):
	if body.is_in_group("hurtful") && body.state < 3:
		body.freeze(true)
		body.wave_freezetime = freezetime
		if !pierce:
			queue_free()
		else:
			pass
	
