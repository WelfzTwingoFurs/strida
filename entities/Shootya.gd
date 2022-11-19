extends KinematicBody2D

enum STATES {IDLE,ATTACK,JUMP,OUCH,DIE}
export(int) var state = STATES.IDLE
var motion = Vector2(0,0)

const TOP_SPEED = 100
const ACCEL = 0.2
const DEACCEL = 0.5
const JUMP = 350
const GRAVITY = 10



func change_state(new_state):
	state = new_state

func _ready():
	player = Global.player
	$Sprite.material = $Sprite.material.duplicate()

var facing = 1
var player
var distanceXY = Vector2(INF,INF)
var distanceA = INF

var on_tile

func _physics_process(_delta):
	match state:
		STATES.IDLE:
			idle()
		STATES.ATTACK:
			attack()
		STATES.JUMP:
			jump()
		STATES.OUCH:
			if is_on_floor():
				motion.x = lerp(motion.x,0,DEACCEL/10)
		STATES.DIE:
			die()
	
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.y += GRAVITY
	
	###########################################################################
	
	if facing != 0:
		$Sprite.scale.x = facing
		$Behind.position.x = -9*facing
		$Behind.cast_to.x = facing
	distanceXY = player.position - position
	distanceA = player.position.distance_to(position)
	
	###########################################################################
	
	on_tile = Global.TileZone.get_cellv( Global.TileZone.world_to_map(position) )
	
#	if on_tile < 1: #straight floor or air
#		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(8,32), Vector2(-8,32)]
#
#	elif on_tile == 1: #1x1
#		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(8,16), Vector2(-8,32)]
#
#	elif on_tile == 2: #2x1
#		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(8,24), Vector2(-8,32)]
#
#	elif on_tile == 3: #1x2
#		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(-8,32), Vector2(-8,32)]
#
#	if Global.TileZone.is_cell_x_flipped( Global.TileZone.world_to_map(position).x, Global.TileZone.world_to_map(position).y ):
#		$ColPoly.scale.x = -1
#	else:
#		$ColPoly.scale.x = 1
	
	################################################################################
	
	


func _process(_delta):
	if $Sprite.frame == 9 or HP < 1 or $AniPlay.current_animation == "freeze":
		$Sprite.modulate.a = 0 if Engine.get_frames_drawn() % 2 == 0 else 1
	else:
		$Sprite.modulate.a = 1.0
	







var chasing = 0
export var readyfire = false

func idle():
	if $AniPlay.current_animation != "draw" && $AniPlay.current_animation != "holster":#animation is busy
		if abs(motion.x) < 1:#stopped
			$AniPlay.playback_speed = 1
			if chasing < 1 && readyfire: #player outta sight, still readyfire
				if is_on_floor(): $AniPlay.play("holster") #holster
			else: #player in sight, or not readyfire
				$AniPlay.stop()
				if is_on_floor():
					if readyfire: $Sprite.frame = 2
					else: $Sprite.frame = 0
				else:
					$Sprite.frame = 11
			
		else:#walk
			if is_on_floor():
				$AniPlay.playback_speed = abs(motion.x/50)
				if sign(motion.x) == facing: $AniPlay.play("walk")
				else: $AniPlay.play("walkb")
			else:
				$Sprite.frame = 11
	
	
	#if (abs(distanceXY.x) < abs(get_viewport().size.x/2)) && (abs(distanceXY.y) < abs(get_viewport().size.y/2)): #player in screen range
	if abs(distanceXY.x) < 320 && abs(distanceXY.y) < 170:
		$Sprite.modulate = Color(1,1,1,1)
		
		if chasing < 1: #timer 0, idle but look out
			motion.x = lerp(motion.x,0,DEACCEL/10)
			$Vision.cast_to = distanceXY #cast to player!
			if $Vision.is_colliding() && $Vision.get_collider().is_in_group("player"):
				chasing = 50 #we got a hit, reset timer
			
		
		else:#if chasing > 0: chasing 'em
			if !$Vision.is_colliding() or ($Vision.is_colliding() && !$Vision.get_collider().is_in_group("player")): #player outta sight
				$Vision.cast_to = distanceXY #cast to player!
				chasing -= 1 #interest timer is ticking down
			else:
				chasing = 50 #saw 'em again, reset timer
			
			
			facing = sign(distanceXY.x)
			
			if abs(distanceXY.x) > 100: #close in Y, far in X, attack
				if abs(distanceXY.x) < 200 && abs(distanceXY.y) < 20: #too far
					change_state(STATES.ATTACK)
				else: #walk there
					motion.x = lerp(motion.x,abs(TOP_SPEED/on_tile)*facing,ACCEL)
					
			
			
			if abs(distanceXY.x) > 100: #far in X, stop
				motion.x = lerp(motion.x,0,DEACCEL/5)
			
			else: #too close, step away
				readyfire = true
				motion.x = lerp(motion.x,abs(TOP_SPEED/on_tile)*-facing,ACCEL/10)
				
				if $Behind.is_colliding(): #wall behind us, skip all and shoot
					change_state(STATES.ATTACK)
				
			
			#if (player.jump_check == false) && (sign(distanceXY.y) == -1) && (abs(motion.x) > TOP_SPEED-1/2): #jump #(motion.x > TOP_SPEED*facing/2)
			if (sign(distanceXY.y) == -1) && abs(distanceXY.y) > 20 && is_on_floor() && abs(distanceXY.x) < 200:#&& abs(distanceXY.x) > 100:# && readyfire:
				readyfire = true
				change_state(STATES.JUMP)
		
		
		
	else: #out of screen, stop walking
		if OS.get_window_size()/Global.zoom > Vector2(640, 340):
			$Sprite.modulate = Color(0,0,0,1)
		
		if chasing < 1:
			motion.x = lerp(motion.x,0,DEACCEL/10)
		else:
			chasing -= 1
			motion.x = lerp(motion.x,abs(TOP_SPEED/on_tile)*facing,ACCEL)
	
		########################################################################

func audio_step():
	Global.audio.STEPs()

################################################################################

func attack():
	facing = sign(distanceXY.x)
	chasing -= 1
	motion.x = lerp(motion.x,0,DEACCEL)
	
	if !readyfire:
		if is_on_floor(): $AniPlay.play("draw")#readyfire true anim
	else:
		$AniPlay.playback_speed = 1
		if is_on_floor():
			if $Behind.is_colliding(): $AniPlay.play("shoot2")
			else: $AniPlay.play("shoot")
		else: $AniPlay.play("shootair")
		

func shoot_lazer():
	audio_shoot()
	lazer()

func audio_shoot():
	Global.audio.YAOWs()

const lazer_shot = preload("res://entities/Shootya-lazer.tscn")

func lazer():
	var boom_instance = lazer_shot.instance()
	boom_instance.facing = facing
	boom_instance.position = position + Vector2(facing*24, -22)
	get_parent().add_child(boom_instance)



################################################################################

func jump():
	motion.x = lerp(motion.x,0,DEACCEL/10)
	$AniPlay.playback_speed = 1
	$AniPlay.play("jump")

func jump_do():
	if is_on_floor_or_wall():
		Global.audio.JUMPs()
		motion.y -= JUMP





################################################################################

onready var HP = 30

func ouch(damage,knockback, time):
	readyfire = true
	change_state(STATES.OUCH)
	motion.x = knockback.x/2
	motion.y = knockback.y
	
	$AniPlay.stop()
	$AniPlay.playback_speed = time
	$AniPlay.play("ouch")
	
	HP -= damage
	if HP < 1:
		die_start()
		die()

func audio_boommed():
	Global.audio.BOOMMEDs()



################################################################################

var wave_freezetime = 1

func freeze(_projectile):
	if state < 3:
		change_state(STATES.OUCH)
		
		#if state != 4:
		motion /= 3
		$AniPlay.stop()
		$AniPlay.playback_speed = wave_freezetime
		Global.audio.BEEPs()
		$AniPlay.play("freeze")





################################################################################

const boom_shot = preload("res://entities/Boom.tscn")
export var timer = 0 #used for sprite explosion in shader

func die():
	change_state(STATES.DIE)
	timer += 0.01
	
	$Sprite.material.set_shader_param("timer", timer)
	if timer > 0.5:
		queue_free()
	#elif (timer > 0.25 && (is_on_floor() or is_on_ceiling() or is_on_wall())):
	#	boom()
	#	queue_free()


func die_start():
	$ColPoly.set_deferred("disabled", true)
	$AniPlay.stop()
	$Sprite.texture = load("res://sprites/deadshootya.png")
	#$Sprite.position.y = 0
	$Sprite.hframes = 1
	$Sprite.vframes = 1
	$Sprite.frame = 0
	
	motion.x *= 2
	motion.y *=2
	
	boom()
	Global.audio.BOOMBIGs()

func boom():
	var boom_instance = boom_shot.instance()
	boom_instance.position = position
	get_parent().add_child(boom_instance)

################################################################################






func is_on_floor_or_wall():
	if is_on_floor(): return true
	elif is_on_wall() && on_tile > 1: return true
	
	return false



