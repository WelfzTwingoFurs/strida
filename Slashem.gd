extends KinematicBody2D

enum STATES {IDLE,ATTACK,JUMP,OUCH,DIE}
export(int) var state = STATES.IDLE
var motion = Vector2(0,0)

const TOP_SPEED = 175
const ACCEL = 0.5
const DEACCEL = 0.25
const JUMP = 250
const GRAVITY = 10



func change_state(new_state):
	state = new_state

func _ready():
	player = Global.player



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
			pass
		STATES.DIE:
			die()
	
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.y += GRAVITY
	
	###########################################################################
	
	if facing != 0:
		$Sprite.scale.x = facing
		$Area/Col.position.x = 12*facing
	distanceXY = player.position - position
	distanceA = player.position.distance_to(position)
	
	###########################################################################
	
	on_tile = Global.TileZone.get_cellv( Global.TileZone.world_to_map(position) )
	
	if on_tile < 1: #straight floor or air
		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(8,32), Vector2(-8,32)]
	
	elif on_tile == 1: #1x1
		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(8,16), Vector2(-8,32)]
	
	elif on_tile == 2: #2x1
		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(8,24), Vector2(-8,32)]
	
	elif on_tile == 3: #1x2
		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(-8,32), Vector2(-8,32)]
	
	if Global.TileZone.is_cell_x_flipped( Global.TileZone.world_to_map(position).x, Global.TileZone.world_to_map(position).y ):
		$ColPoly.scale.x = -1
	else:
		$ColPoly.scale.x = 1
	
	################################################################################
	
	
	
	if $Sprite.frame == 9 or HP < 1:
		$EffectPlay.play("_ready")
	else:
		$EffectPlay.stop()
		$Sprite.visible = true
	









func idle():
	if abs(distanceA) < 40: #close, attack
		change_state(STATES.ATTACK)
	
	
	if is_on_floor_or_wall():
		if abs(motion.x) < 1:
			$AniPlay.stop()
			$Sprite.frame = 0
		else:
			$AniPlay.playback_speed = abs(motion.x/200)
			$AniPlay.play("walk")
			
		
		
		
		
		
		if (abs(distanceXY.x) < abs(get_viewport().size.x/2)) && (abs(distanceXY.y) < abs(get_viewport().size.y/2)): #in screen, walk
			facing = sign(distanceXY.x)
			if abs(distanceXY.x) > 25:
				motion.x += facing
				motion.x = lerp(motion.x,abs(TOP_SPEED/on_tile)*facing,ACCEL/10)
			else: #too close, stop
				motion.x = lerp(motion.x,0,DEACCEL/5)
			
			if (player.jump_check == false) && (sign(distanceXY.y) == -1) && (abs(motion.x) > TOP_SPEED-1/2): #jump #(motion.x > TOP_SPEED*facing/2)
				change_state(STATES.JUMP)
			
			
			
		else: #out of screen, stop walking
			motion.x = lerp(motion.x,0,DEACCEL/10)
		
		########################################################################
	else:
		motion.x = lerp(motion.x,0,DEACCEL/100)
		$AniPlay.stop()
		$Sprite.frame = 5
	
	

################################################################################


func attack():
	motion.x = lerp(motion.x,0,DEACCEL)
	$AniPlay.playback_speed = 1
	$AniPlay.play("attack")

func audio_uw():
	Global.audio.UWs()

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.ouch(25,Vector2(50*facing,-100))



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

onready var HP = 40

func ouch(damage,knockback):
	change_state(STATES.OUCH)
	motion.x = knockback.x
	motion.y = knockback.y
	
	$AniPlay.stop()
	$AniPlay.playback_speed = 1
	$AniPlay.play("ouch")
	
	HP -= damage
	if HP < 1:
		die_start()
		die()

func audio_boommed():
	Global.audio.BOOMMEDs()



################################################################################



func freeze():
	if HP > 0:
		change_state(STATES.OUCH)
		
		motion /= 2
		$AniPlay.stop()
		$AniPlay.playback_speed = 1
		$AniPlay.play("freeze")

func audio_beep():
	Global.audio.BEEPs()





################################################################################

const boom_shot = preload("res://Boom.tscn")
var timer = 0

func die():
	change_state(STATES.DIE)
	
	timer += 1
	
	if timer > 45 or (timer > 10 && (is_on_floor() or is_on_ceiling() or is_on_wall())):
		boom()
		queue_free()


func die_start():
	boom()
	$AniPlay.stop()
	$Sprite.frame = 19
	#motion.x = 150*sign(motion.x)
	#motion.y = -300
	motion.x *= 2
	motion.y *=2
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



