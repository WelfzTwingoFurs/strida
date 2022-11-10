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
		if id == 0: #wave
			body.pow_wave = true
		elif id == 1: #repeat
			body.pow_repeat = true
		elif id == 2: #plus wave motion
			body.pow_motion += 1
		elif id == 3: #plus wave scale
			body.pow_scale += 1
		elif id == 4: #double wave
			body.pow_double = true
		elif id == 5: #piercing
			body.pow_piercing = true
		elif id == 6: #kicks don't stop
			body.pow_nostop = true
		elif id == 7: #plus health
			if body.HP < 140: body.HP += 10
			else:
				body.HP = 150
		elif id == 8: #plus damage
			body.pow_damage += 10
		elif id == 9: #kick faster
			body.pow_kicktime *= 1.2
		elif id == 10: #wave lasts longer
			body.pow_wavetime /= 1.5
		elif id == 11: #freeze lasts longer
			body.pow_freezetime /= 1.5
		elif id == 12:
			body.pow_kickstuntime /= 1.5
		
		Global.audio.GETMEDs()
		queue_free()
