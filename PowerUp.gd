extends KinematicBody2D

export var id = 0
var motion = Vector2(0,0)
const GRAVITY = 10

func _ready():
	$Sprite.frame = id

func _physics_process(_delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	
	if !is_on_floor():
		motion.y += GRAVITY
	motion.x = 0


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		if id == 0:
			body.pow_wave = true
		elif id == 1:
			body.pow_repeat = true
		elif id == 2:
			body.pow_motion += 1
		elif id == 3:
			body.pow_scale += 0.5
		
		Global.audio.SHOOTs()
		queue_free()
