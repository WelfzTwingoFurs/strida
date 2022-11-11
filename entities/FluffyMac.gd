extends KinematicBody2D

enum STATES {IDLE,ATTACK,JUMP,OUCH,DIE}
export(int) var state = STATES.IDLE
var motion = Vector2(0,0)

const TOP_SPEED = 100
const ACCEL = 0.5
const DEACCEL = 0.25
const JUMP = 250
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
			pass
		STATES.OUCH:
			if is_on_floor():
				motion.x = lerp(motion.x,0,DEACCEL/10)
			pass
		STATES.DIE:
			die()
	
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.y += GRAVITY
	
	###########################################################################
	
	if facing != 0:
		$Sprite.scale.x = facing
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

func idle():
	$AniPlay.playback_speed = 1
	$Area/Col.disabled = true
	
	if is_on_floor_or_wall():
		if abs(motion.x) < 10:
			$AniPlay.stop()
			if chasing < 1:
				$Sprite.frame = 0
			else:
				$Sprite.frame = 10
		else:
			$AniPlay.play("walk")
			
		
		
		
		
		
		#if (abs(distanceXY.x) < abs(get_viewport().size.x/2)) && (abs(distanceXY.y) < abs(get_viewport().size.y/2)): #player in screen range
		if abs(distanceXY.x) < 320 && abs(distanceXY.y) < 170: #player in screen range
			$Sprite.modulate = Color(1,1,1,1)
			
			if chasing < 1: #timer 0, idle but look out
				motion.x = lerp(motion.x,0,DEACCEL/10)
				$Vision.cast_to = distanceXY #cast to player!
				if $Vision.is_colliding() && $Vision.get_collider().is_in_group("player"):
					chasing = 100 #we got a hit, reset timer
				
			
			else:#if chasing > 0:
				if !$Vision.is_colliding() or ($Vision.is_colliding() && !$Vision.get_collider().is_in_group("player")): #player outta sight
					$Vision.cast_to = distanceXY #cast to player!
					chasing -= 1 #interest timer is ticking down
				else:
					chasing = 100 #saw 'em again, reset timer
				
				
				if abs(distanceXY.x) < 25: #close, attack
					if abs(distanceXY.y) < 25:
						$AniPlay.play("attack")
						change_state(STATES.ATTACK)
					elif sign(distanceXY.y) == -1:
						motion.y -= JUMP
						$AniPlay.play("upper")
						change_state(STATES.JUMP)
				
				facing = sign(distanceXY.x)
				if abs(distanceXY.x) > 25:
					motion.x += facing
					motion.x = lerp(motion.x,abs(TOP_SPEED/on_tile)*facing,ACCEL/10)
				else: #too close, stop
					motion.x = lerp(motion.x,0,DEACCEL/5)
				
			
			
			
		else: #out of screen, stop walking
			if OS.get_window_size()/Global.zoom > Vector2(640, 340):
				$Sprite.modulate = Color(0,0,0,1)
			
			if chasing < 1:
				motion.x = lerp(motion.x,0,DEACCEL/10)
			else:
				chasing -= 1
				motion.x = lerp(motion.x,abs(TOP_SPEED/on_tile)*facing,ACCEL/10)
		
		########################################################################
	else:
		motion.x = lerp(motion.x,0,DEACCEL/100)
		$AniPlay.stop()
		$Sprite.frame = 5
	
	

func audio_step():
	Global.audio.STEPs()

################################################################################


func attack():
	motion.x = lerp(motion.x,0,DEACCEL)


func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.ouch(30,Vector2(facing*10,-100),2)
		
		$Area/Col.set_deferred("disabled", true)
		
		if $AniPlay.current_animation != "upper":
			motion.x = -facing*100
			$AniPlay.stop()
			$AniPlay.playback_speed /= 1.4
			
			if $AniPlay.current_animation == "attackL":
				$AniPlay.play("attackR")
			else:
				$AniPlay.play("attackL")
		

func lunge():
	$Area/Col.position = Vector2(11*facing, -20)
	Global.audio.UWs()
	motion.x += facing*200
	motion.y -= 20

################################################################################

onready var HP = 50

func ouch(damage,knockback, time):
	change_state(STATES.OUCH)
	$Area/Col.set_deferred("disabled", true)
	
	if abs(distanceXY.x) < 10:
		motion.x = knockback.x/2
	else:
		motion.x = knockback.x/5
	motion.y = knockback.y/2
	
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

func freeze():
	if state < 2:
		motion.y -= JUMP
		$AniPlay.stop()
		$AniPlay.play("upper")
		change_state(STATES.JUMP)

func freeze_lunge():
	$Area/Col.position = Vector2(0, -32)
	Global.audio.UWs()



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
	$AniPlay.stop()
	$Sprite.texture = load("res://sprites/deadslashem.png")
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



