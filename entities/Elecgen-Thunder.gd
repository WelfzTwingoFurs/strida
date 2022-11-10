extends KinematicBody2D

func _process(_delta):#very colorful indeed!!
	modulate.a = 0 if Engine.get_frames_drawn() % 2 == 0 else 1

var motion = Vector2(0,0)
var facing = Vector2(0,1)

const TOP_SPEED = 350
const ACCEL = 1

func _ready():
	$AniPlay.play("_ready")
	if facing.x != 0: $Sprite.scale.x = facing.x
	$Sprite.rotation_degrees = facing.y * 90

func _physics_process(_delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.x = lerp(motion.x,TOP_SPEED*facing.x,ACCEL)
	motion.y = lerp(motion.y,TOP_SPEED*facing.y,ACCEL)
	
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		die()

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.freeze(1)
		die()


const boom_shot = preload("res://entities/Boom.tscn")

func die():
	boom()
	queue_free()

func boom():
	var boom_instance = boom_shot.instance()
	boom_instance.position = position + Vector2(facing.x*8,0)
	get_parent().add_child(boom_instance)
