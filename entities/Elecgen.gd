extends KinematicBody2D

enum STATES {IDLE,ATTACK,JUMP,OUCH,DIE}
export(int) var state = STATES.IDLE
var motion = Vector2(0,0)

const TOP_SPEED = 350
const GRAVITY = 20


func change_state(new_state):
	state = new_state

func _ready():
	$Vision.enabled = true
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
				motion.x = lerp(motion.x,0,0.5)
		STATES.DIE:
			die()
	
	motion = move_and_slide(motion, Vector2(0,-1))
	if $Sprite.frame != 3 && $Sprite.frame != 4 && $Sprite.frame != 5 && $Sprite.frame != 6 && $Sprite.frame != 7 && $Sprite.frame != 1 && $Sprite.frame != 2:
		#$ColPoly.disabled = false
		motion.y += GRAVITY
	else:
		#$ColPoly.disabled = true
		motion.y = 0
	
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
	if $Sprite.frame == 7 or $Sprite.frame == 9 or HP < 1 or $AniPlay.current_animation == "freeze":
		$Sprite.modulate.a = 0 if Engine.get_frames_drawn() % 2 == 0 else 1
	else:
		$Sprite.modulate.a = 1.0
	







var chasing = 0

func idle():
	$AniPlay.playback_speed = 1
	$Vision.enabled = true 
	motion.x = 0
	
	#if (abs(distanceXY.x) < abs(get_viewport().size.x/2)) && (abs(distanceXY.y) < abs(get_viewport().size.y/2)): #player in screen range
	if abs(distanceXY.x) < 320 && abs(distanceXY.y) < 170: #player in screen range
		$Sprite.modulate = Color(1,1,1,1)
		$Vision.cast_to = distanceXY
		
		if $Vision.is_colliding() && $Vision.get_collider().is_in_group("player"):
			chasing = true
			facing = sign(distanceXY.x)
			
			if (abs(distanceXY.y) < 50): #close, attack
				if Global.player.state == 3:
					$AniPlay.play("attackquick")
				else:
					$AniPlay.play("attack")
				
				change_state(STATES.ATTACK)
			else:
				$AniPlay.stop()
				$Sprite.frame = 0
			
			#if abs(distanceXY.x) < 10 && distanceXY.y > 5:
			#	$AniPlay.play("shootdown")
			#	change_state(STATES.ATTACK)
		
		else:#if chasing > 0:
			$AniPlay.stop()
			$Sprite.frame = 0
			chasing = false
			
			
		
		
		
	else: #out of screen, stop walking
		$AniPlay.stop()
		$Sprite.frame = 0
		if OS.get_window_size()/Global.zoom > Vector2(640, 340):
			$Sprite.modulate = Color(0,0,0,1)
		
		chasing = false
		

################################################################################


func attack():
	$Vision.cast_to = Vector2(0,-9999)
	if $Vision.cast_to.y == -9999 && $Vision.is_colliding() && $Vision.get_collider().is_in_group("player"):
		$AniPlay.play("shootup")
	
	if !$AniPlay.is_playing():
		if abs(distanceXY.x) > 320 or abs(distanceXY.y) > 170 or ($Vision.is_colliding() && !$Vision.get_collider().is_in_group("player")) or !$Vision.is_colliding():
			change_state(STATES.IDLE)
	
	#if on_tile > 1:
	#	if $Sprite.frame == 3 or $Sprite.frame == 4 or $Sprite.frame == 5 or $Sprite.frame == 6 or $Sprite.frame == 7:# or $Sprite.frame == 1 or $Sprite.frame == 2:
	#	charge()

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.ouch(35,Vector2(100*facing,-100),0.5)
		$Vision.enabled = false
		
		if $AniPlay.current_animation == "attack":
			motion += Vector2(500*-facing,-100)
		
		$Area/Col.set_deferred("disabled", true)#do this to avoid knockbackin' back into the same hitbox


func charge():
	motion.x = TOP_SPEED*facing

func stop():
	motion.x /= 2

func shoot_lazer():
	audio_shoot()
	lazer(Vector2(facing,0))

func shoot_lazer_up():
	audio_shoot()
	lazer(Vector2(0,-1))

func shoot_lazer_down():
	audio_shoot()
	lazer(Vector2(0,1))

func audio_shoot():
	Global.audio.SHOOTs()

const lazer_shot = preload("res://entities/Elecgen-Thunder.tscn")

func lazer(dir):
	var boom_instance = lazer_shot.instance()
	boom_instance.facing.x = dir.x
	boom_instance.facing.y = dir.y
	boom_instance.position = position + Vector2(dir.x*24, -22)
	get_parent().add_child(boom_instance)




################################################################################

################################################################################

onready var HP = 40

func ouch(damage,knockback, time):
	if $Sprite.frame != 3 && $Sprite.frame != 4 && $Sprite.frame != 5 && $Sprite.frame != 6 && $Sprite.frame != 7:
		change_state(STATES.OUCH)
		$Area/Col.set_deferred("disabled", true)
		motion.x = knockback.x*4.5
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

func freeze():
	if state < 3:
		if $Sprite.frame != 3 && $Sprite.frame != 4 && $Sprite.frame != 5 && $Sprite.frame != 6 && $Sprite.frame != 7 && $Sprite.frame != 1 && $Sprite.frame != 2:
			change_state(STATES.OUCH)
			$Area/Col.set_deferred("disabled", true)
			
			#if state != 4:
			motion /= 3
			$AniPlay.stop()
			$AniPlay.playback_speed = wave_freezetime
			Global.audio.BEEPs()
			$AniPlay.play("freeze")
		else:
			$AniPlay.play("shootup")





################################################################################

const boom_shot = preload("res://entities/Boom.tscn")
export var timer = 0 #used for sprite explosion in shader

func die():
	change_state(STATES.DIE)
	timer += 0.01
	
	$Sprite.material.set_shader_param("timer", timer)
	if timer > 0.5:
		queue_free()


func die_start():
	$ColPoly.set_deferred("disabled", true)
	$AniPlay.stop()
	$Sprite.texture = load("res://sprites/deadelegen.png")
	$Sprite.hframes = 1
	$Sprite.vframes = 1
	$Sprite.frame = 0
	
	motion.x /= 2
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



