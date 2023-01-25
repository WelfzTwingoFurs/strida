extends KinematicBody2D

enum STATES {IDLE,ATTACK,JUMP,OUCH,DIE}
export(int) var state = STATES.IDLE
var motion = Vector2(0,0)

const SPEED = 100
const ACCEL = 0.5
const GRAVITY = 10

func change_state(new_state):
	state = new_state

func _ready():
	player = Global.player
	$Sprite.material = $Sprite.material.duplicate()

var facing = 1
var player
var dist_player = Vector2(INF,INF)
var dist_camera = Vector2(INF,INF)
var distanceA = INF

var on_tile

func _process(_delta):
	match state:
		STATES.IDLE:
			idle()
		STATES.ATTACK:
			push()
		STATES.JUMP:
			pass
		STATES.OUCH:
			motion.x = lerp(motion.x,0,0.01)
		STATES.DIE:
			die()
	
	###########################################################################

	
	###########################################################################
	
	dist_player = player.position - position
	dist_camera = player.camerapos - position
	distanceA = player.position.distance_to(position)
	
	###########################################################################
	
	on_tile = Global.TileZone.get_cellv( Global.TileZone.world_to_map(position) )
	
	###########################################################################
	###########################################################################
	
	if $Sprite.frame == 9:# or HP < 1 or $AniPlay.current_animation == "freeze":
		$Sprite.modulate.a = 0 if Engine.get_frames_drawn() % 2 == 0 else 1
	else:
		$Sprite.modulate.a = 1.0
	

func _physics_process(_delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.y += GRAVITY
	
	if facing != 0:
		$Sprite.scale.x = facing
		$ColPoly.scale.x = -facing
		$Area/Col.position.x = 3*facing
		$FloorcheckL.position.x = 7*facing
		$FloorcheckR.position.x = 25*facing


var dir = 1
var was_dir = 1
var chasing = 0

func idle():
	if abs(dist_camera.x) < 320 && abs(dist_camera.y) < 170: #player in screen range
		$Sprite.modulate = Color(1,1,1,1)
		dir = sign(dist_player.x)
		
		if chasing < 1:
			$Vision.cast_to = dist_player #cast to player!
			if $Vision.is_colliding() && $Vision.get_collider().is_in_group("player"):
				chasing = 50 #we got a hit, reset timer
		else:
			if !$Vision.is_colliding() or ($Vision.is_colliding() && !$Vision.get_collider().is_in_group("player")): #player outta sight
				$Vision.cast_to = dist_player
				chasing -= 1
			else:
				chasing = 50
			
			
			
			
			if on_me:
				motion.x = 0
				$AniPlay.stop()
				$Sprite.frame = 6
				
			else:
				if dir == was_dir && $Sprite.frame < 3:# && $AniPlay.current_animation != "turn":
					if dist_player.y < 0 && ($FloorcheckL.is_colliding() or $FloorcheckR.is_colliding()):
						$AniPlay.playback_speed = abs(motion.x/50)
						$AniPlay.play("walk")
						motion.x = lerp(motion.x,SPEED*facing,ACCEL)
					else:
						$AniPlay.stop()
						$Sprite.frame = 1
						motion.x = lerp(motion.x,0,ACCEL)
				
				else:
					$AniPlay.playback_speed = 1
					$AniPlay.play("turn")
					motion.x = lerp(motion.x,0,ACCEL)
		
		
	else:
		if OS.get_window_size()/Global.zoom > Vector2(640, 340):
			$Sprite.modulate = Color(0,0,0,1)
		
		if chasing > 1:
			chasing -= 1
			if !($FloorcheckL.is_colliding() or $FloorcheckR.is_colliding()):
				motion.x = 0#keep motion, don't modify it unless
		else:
			motion.x = lerp(motion.x,0,ACCEL)
		



func turn_around():#jump up jump up and get down JUMP JUMP JUMP JUMP
	facing = -$Sprite.scale.x
	was_dir = facing

func face_player():
	facing = sign(dist_player.x)
	was_dir = facing

var on_me = false

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		on_me = true

func _on_Area_body_exited(body):
	if body.is_in_group("player"):
		on_me = false

###########################################################################

func push():
	pass

################################################################################

var HP = 50

func ouch(damage,knockback, time):
	if on_me:
		change_state(STATES.OUCH)
		$AniPlay.stop()
		$AniPlay.play("hittop")
		$AniPlay.playback_speed = 1
		
	else:
		
		change_state(STATES.OUCH)
		motion.x += knockback.x/5
		motion.y = 100
		dir = sign(dist_player.x)
		
		$AniPlay.stop()
		if dir == facing:
			if abs(motion.x/100) > 1: $AniPlay.playback_speed = abs(motion.x/100)
			else: $AniPlay.playback_speed = 1
			$AniPlay.play("pushback")
			
		else:
			$AniPlay.playback_speed = time
			Global.audio.BOOMMEDs()
			motion.x *= 2
			$AniPlay.play("ouch")
			HP -= damage
			
		
		
		if HP < 1:
			motion.y = knockback.y
			die_start()
			change_state(STATES.DIE)



################################################################################

var wave_freezetime = 1

func freeze(_projectile):
	if state < 3:
		change_state(STATES.OUCH)
		
		motion /= 3
		$AniPlay.stop()
		$AniPlay.playback_speed = wave_freezetime
		$AniPlay.play("freeze")
		Global.audio.BEEPs()

var timer = 0
func die():
	$AniPlay.stop()
	$Sprite.material.set_shader_param("timer", timer)
	timer += 0.01
	
	if timer > 1:
		queue_free()

const boom_shot = preload("res://entities/Boom.tscn")
func die_start():
	$ColPoly.set_deferred("disabled", true)
	$AniPlay.stop()
	$Sprite.texture = load("res://sprites/deadbear.png")
	#$Sprite.position.y = 0
	$Sprite.hframes = 1
	$Sprite.vframes = 1
	$Sprite.frame = 0
	
	motion.x *= 2
	motion.y *=2
	
	var boom_instance = boom_shot.instance()
	boom_instance.position = position
	get_parent().add_child(boom_instance)
	Global.audio.BOOMBIGs()

func audio_step():
	Global.audio.STEPs()
