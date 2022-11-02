extends KinematicBody2D

enum STATES {IDLE,ATTACK,JUMP}
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
	
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.y += GRAVITY
	
	###########################################################################
	
	if facing != 0: $Sprite.scale.x = facing
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




func idle():
	facing = sign(distanceXY.x)
	
	
	if abs(distanceA) < 50: #close, attack
		Global.audio.JUMPLANDs()
		change_state(STATES.ATTACK)
	
	
	if is_on_floor_or_wall():
		if abs(motion.x) < 1:
			$AniPlay.stop()
			$Sprite.frame = 0
		else:
			$AniPlay.playback_speed = abs(motion.x/200)
			$AniPlay.play("walk")
			
		
		if player.jump_check == false && sign(distanceXY.y) == -1: #jump
			change_state(STATES.JUMP)
		
		
		
		
		if (abs(distanceXY.x) < abs(get_viewport().size.x/2)): #in screen, walk
			motion.x += facing
			motion.x = lerp(motion.x,abs(TOP_SPEED/on_tile)*facing,ACCEL)
			
			
		else: #out of screen, stop walking
			motion.x = lerp(motion.x,0,DEACCEL/10)
		
		########################################################################
	else:
		motion.x = lerp(motion.x,0,DEACCEL/100)
		$AniPlay.stop()
		$Sprite.frame = 5
	
	




func attack():
	motion.x = lerp(motion.x,0,DEACCEL)
	$AniPlay.playback_speed = 1
	$AniPlay.play("attack")

func jump():
	motion.x = lerp(motion.x,0,DEACCEL/10)
	$AniPlay.playback_speed = 1
	$AniPlay.play("jump")

func jump_do():
	if is_on_floor_or_wall():
		Global.audio.JUMPs()
		motion.y -= JUMP


func is_on_floor_or_wall():
	if is_on_floor(): return true
	elif is_on_wall() && on_tile > 1: return true
	
	return false
