extends KinematicBody2D

#export var top_bot = Vector2(10,10)
export var speed = 5
var player
var motion = Vector2(0,0)

#func _ready():
#	top_bot = Vector2(position.y-top_bot.x,position.y+top_bot.y)

func _physics_process(_delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	
	if player:
		if Input.is_action_pressed("ply_up"):
			#if position.y < top_bot.x:
				motion.y = -speed
			#else:
			#	motion.y = 0
		elif Input.is_action_pressed("ply_down"):
			#if position.y > top_bot.y:
				motion.y = speed
			#else:
			#	motion.y = 0
		else:
			motion.y = lerp(motion.y,0,0.2)
	else:
		motion.y = lerp(motion.y,0,0.2)


func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		player = true
		body.elevator = self


func _on_Area_body_exited(body):
	if body.is_in_group("player") && player == true:
		player = false
		body.elevator = null
