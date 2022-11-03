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
			body.pow_scale += 1
		elif id == 4:
			body.pow_double = true
		elif id == 5:
			body.pow_piercing = true
		elif id == 6:
			body.pow_nostop = true
		elif id == 7:
			if body.HP < 140: body.HP += 10
			else:
				body.HP = 150
		elif id == 8:
			body.pow_damage += 10
		
		Global.audio.GETSMALLs()
		queue_free()
