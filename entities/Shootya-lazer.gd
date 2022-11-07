extends KinematicBody2D

func _process(_delta):#very colorful indeed!!
	$Sprite.modulate.a = 0 if Engine.get_frames_drawn() % 2 == 0 else 1
	
	if $Sprite.frame == 0:
		$Sprite.frame = 0 if Engine.get_frames_drawn() % 2 == 0 else 1
		
	elif $Sprite.frame == 1:
		$Sprite.frame = 1 if Engine.get_frames_drawn() % 2 == 0 else 2
		
	elif $Sprite.frame == 2:
		$Sprite.frame = 2 if Engine.get_frames_drawn() % 2 == 0 else 3
		
	elif $Sprite.frame == 3:
		$Sprite.frame = 3 if Engine.get_frames_drawn() % 2 == 0 else 4
		
	elif $Sprite.frame == 4:
		$Sprite.frame = 4 if Engine.get_frames_drawn() % 2 == 0 else 5
		
	elif $Sprite.frame == 5:
		$Sprite.frame = 5 if Engine.get_frames_drawn() % 2 == 0 else 6
		
	elif $Sprite.frame == 6:
		$Sprite.frame = 6 if Engine.get_frames_drawn() % 2 == 0 else 7
		
	elif $Sprite.frame == 7:
		$Sprite.frame = 7 if Engine.get_frames_drawn() % 2 == 0 else 0

var motion = Vector2(0,0)
var facing = 1

const TOP_SPEED = 500
const ACCEL = 0.1

var ready_pos
func _ready():
	ready_pos = position
	$Sprite.scale.x = facing
	$Sprite2.scale.x = facing

export var daddy = Vector2(0,0)

func _physics_process(_delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.x = lerp(motion.x,TOP_SPEED*facing,ACCEL)
	
	position.y = ready_pos.y
	$Sprite2.position = ready_pos - position
	
	
	if is_on_floor() or is_on_wall() or is_on_wall():
		die()

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.ouch(30,Vector2(10*facing,-10),2)
		die()

func die():
	boom()
	queue_free()

const boom_shot = preload("res://entities/Boom.tscn")

func boom():
	var boom_instance = boom_shot.instance()
	boom_instance.position = position + Vector2(facing*8,0)
	get_parent().add_child(boom_instance)
