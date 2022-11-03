extends KinematicBody2D

enum STATES {IDLE,ATTACK,NOCLIP,OUCH}
export(int) var state = STATES.IDLE
var motion = Vector2(0,0)

var input = Vector2(0,0)
var facing = 1

var on_tile = 0

const TOP_SPEED = 175
const ACCEL = 0.5
const DEACCEL = 0.25
const JUMP = 250
const GRAVITY = 10

func change_state(new_state):
	state = new_state

func _ready():
	Global.player = self
	$Speedo.visible = true
	$Health.visible = true

func _physics_process(_delta):
	match state:
		STATES.IDLE:
			idle()
		STATES.ATTACK:
			kick()
		STATES.NOCLIP:
			noclip()
		STATES.OUCH:
			pass
	
	motion = move_and_slide(motion, Vector2(0,-1))
	update()
	
	########################################################################
	
	motion.y += GRAVITY
	$Sprite.scale.x = facing
	
	########################################################################
	
	
	
	if Input.is_action_pressed("ply_up"):
		input.y = -1
	elif Input.is_action_pressed("ply_down"):
		input.y = 1
	else:
		input.y = 0
	
	
	if Input.is_action_pressed("ply_right"):
		input.x = 1
	elif Input.is_action_pressed("ply_left"):
		input.x = -1
	else:
		input.x = 0
	
	########################################################################
	
	if $Sprite.frame == 30:# or $Sprite.frame == 31:
		$EffectPlay.play("_ready")
	else:
		$EffectPlay.stop()
		$Sprite.visible = true
	
	
	########################################################################
	
	on_tile = Global.TileZone.get_cellv( Global.TileZone.world_to_map(position) )
	
	
	if on_tile < 1: #straight floor or air
		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(8,32), Vector2(-8,32)]
		if is_on_floor(): #Only reset after landing
			$Sprite.position = Vector2(0,-19)
	
	elif on_tile == 1: #1x1
		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(8,16), Vector2(-8,32)]
		if is_on_floor(): #Only reset after landing
			$Sprite.position = Vector2(-3*$ColPoly.scale.x,-19)
	
	elif on_tile == 2: #2x1
		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(8,24), Vector2(-8,32)]
		if is_on_floor(): #Only reset after landing
			$Sprite.position = Vector2(-1*$ColPoly.scale.x,-19)
	
	elif on_tile == 3: #1x2
		$ColPoly.polygon = [Vector2(-8,0), Vector2(8,0), Vector2(-8,32), Vector2(-8,32)]
		if is_on_floor_or_wall(): #Only reset after landing
			$Sprite.position = Vector2(-5*$ColPoly.scale.x, -19)
	
	
	if Global.TileZone.is_cell_x_flipped( Global.TileZone.world_to_map(position).x, Global.TileZone.world_to_map(position).y ):
		$ColPoly.scale.x = -1
	else:
		$ColPoly.scale.x = 1
	
	########################################################################
	
	if is_on_floor() && was_on_floor:
		Global.audio.JUMPLANDs()
		was_on_floor = false
	
	if !is_on_floor():
		was_on_floor = true
	
	########################################################################
	if $JumpCheck.is_colliding():
		jump_check = true
	else:
		jump_check = false
		

var was_on_floor = false
var jump_check = false


################################################################################

func idle():
	if Input.is_action_just_pressed("bug_noclip"): change_state(STATES.NOCLIP)
	
	if Input.is_action_just_pressed("ply_attack"):
		change_state(STATES.ATTACK)
	
	
	if input.x != 0:
		motion.x += input.x#running
		
		if abs(motion.x) < (TOP_SPEED/1.5): #under half speed, slower accel
			motion.x = lerp(motion.x,TOP_SPEED*input.x,ACCEL/3)
			if input.x != facing: #turning around
				$AniPlay.stop()
				$Sprite.frame = 8
				facing = input.x
			
		elif (abs(motion.x) > TOP_SPEED) && (input.x == sign(motion.x)): #over max speed, don't slow down
			facing = sign(motion.x) #kick backwards will keep facing, fix.
			
		
		else: #over half, under over max speed
			if abs(motion.x) < TOP_SPEED+1: #max speed, regular
				facing = input.x
				motion.x = lerp(motion.x,TOP_SPEED*input.x,ACCEL)
				
			else: #max speed, contrary input, deaccel slowly (skid)
				motion.x = lerp(motion.x,0,DEACCEL/10)
				
			
		
	else:#no X input
		if abs(motion.x) < TOP_SPEED+1:#regular, regular deaccel
			motion.x = lerp(motion.x,0,DEACCEL)
		else:#over max speed, slow deaccel
			motion.x = lerp(motion.x,0,DEACCEL/10)
	
	
	
	
	if is_on_floor_or_wall():#if on_floor if on_tile !=3, if on_wall if it is
		if Input.is_action_just_pressed("ply_jump") && (on_tile < 3):#can't jump on a slope too steep
			Global.audio.JUMPs()
			motion.y -= JUMP
			
		
		if (on_tile < 1):
			if (int(motion.x) == 0): #stopped, stand
				$AniPlay.stop()
				$Sprite.frame = 0
				
				
			elif (abs(motion.x) > TOP_SPEED/1.5): #over half speed
				if (abs(motion.x) > TOP_SPEED+1) && (input.x != sign(motion.x)) && (input.x != 0):#over max speed, contrary input, skid
					$AniPlay.stop()
					$Sprite.frame = 7
					
				else:#over half, under over
					$AniPlay.playback_speed = abs(motion.x/200)
					ani_walk()
					
			
		else:#on_tile > 1, we slopin'
			if input.x != 0: facing = input.x
			
			$AniPlay.playback_speed = abs(motion.x/200)
			if input.x == $ColPoly.scale.x:
				ani_walkslope()
					
			elif input.x != 0:
				ani_walk()
				
			elif $Sprite.frame == 6:#if jump then stand, jump frame keeps. fix.
				if facing == $ColPoly.scale.x:
					ani_walkslope()
						
				else:
					ani_walk()
				
			elif input.x == 0:#Don't stay diagonal if standing still, it's silly.
				if int(motion.x) == 0:
					$AniPlay.stop()
					$Sprite.frame = 0
		
		
	else:#if !is_on_floor_or_wall():
		if on_tile != 3:
			if (abs(motion.x) > TOP_SPEED+1) && (input.x != sign(motion.x)) && (input.x != 0):#skidding condition
				$AniPlay.stop()
				$Sprite.frame = 7
			
			else:
				#if on_tile < 1 or $Sprite.frame < 10: #dont jump if diagonal
				$AniPlay.stop()
				if sign(motion.y) == 1:
					$Sprite.frame = 6
					
					
				else:
					$Sprite.frame = 5
				#elif Input.is_action_pressed("ply_jump"):
				#	$AniPlay.stop()
				#	$Sprite.frame = 5 
	
	
	




func ani_walk():#Use this function as we have varying animations
	if on_tile < 1:
		$AniPlay.play("walk")
	elif on_tile == 1:
		$AniPlay.play("walk1")
	elif on_tile == 2:
		$AniPlay.play("walk2")
	elif on_tile == 3:
		$AniPlay.play("walk3")

func ani_walkslope():#Use this function as we have varying animations
	if on_tile == 1:
		$AniPlay.play("walkslope1")
	elif on_tile == 2:
		$AniPlay.play("walkslope2")
	elif on_tile == 3:
		$AniPlay.play("walkslope3")

################################################################################










################################################################################

#kick powers
export var pow_wave = true
export var pow_motion = 1
export var pow_repeat = true
export var pow_scale = 2
export var pow_double = true
export var pow_piercing = true
export var pow_nostop = true
export var pow_damage = 10

func kick():
	$AniPlay.playback_speed = 1
	#don't re-do animation if only input.y is changed
	if $AniPlay.current_animation != "kickhigh" && $AniPlay.current_animation != "kickmid" && $AniPlay.current_animation != "kicklow" && $AniPlay.current_animation != "kickhighair" && $AniPlay.current_animation != "kickmidair" && $AniPlay.current_animation != "kicklowair":
		kick_anim()
	
	if is_on_floor():
		if Input.is_action_just_pressed("ply_jump") && (on_tile < 3):#can't jump on a slope too steep
			motion.y -= JUMP
		
		if abs(motion.x) < TOP_SPEED:
			motion.x = lerp(motion.x,0,DEACCEL/2)
		else:
			motion.x = lerp(motion.x,0,DEACCEL/20)
	elif input.x != facing && input.x != 0:
			motion.x = lerp(motion.x,TOP_SPEED*input.x,ACCEL/10)
	
	
	
	#if ((on_tile == 3) && is_on_floor_or_wall()):
		#	facing = -$ColPoly.scale.x
	
	if pow_repeat:
		if Input.is_action_just_pressed("ply_attack"): #attack more!!
			kick_anim()
		
		


func kick_anim():
	Global.audio.KICKs()
	if input.x != 0: facing = input.x
	$AniPlay.stop()
	
	motion.x += facing*10 + input.x*10
	#if is_on_floor():
	if input.y == -1:
		$Area/Col.position = Vector2(13*facing,-30)
		if is_on_floor(): $AniPlay.play("kickhigh")
		else: $AniPlay.play("kickhighair")
	elif input.y == 0:
		$Area/Col.position = Vector2(18*facing,-16)
		if is_on_floor(): $AniPlay.play("kickmid")
		else: $AniPlay.play("kickmidair")
	elif input.y == 1:
		$Area/Col.position = Vector2(14*facing,-1)
		if is_on_floor(): $AniPlay.play("kicklow")
		else: $AniPlay.play("kicklowair")
#	else:
#		if input.y == -1:
#			$AniPlay.play("kickhighair")
#		elif input.y == 0:
#			$AniPlay.play("kickmidair")
#		elif input.y == 1:
#			$AniPlay.play("kicklowair")


const kick_shot = preload("res://PlayerKick.tscn")

func kick_shoot(pos):
	if pow_wave:
		pos = input.y
		Global.audio.SHOOTs()
		var kick_instance = kick_shot.instance()
		kick_instance.pos = pos
		kick_instance.facing = facing
		kick_instance.pierce = pow_piercing
		
		kick_instance.scale = Vector2(pow_scale,pow_scale)
		
		if pow_motion > 0:
			kick_instance.extra_motion.x = pow_motion*facing
			kick_instance.extra_motion.y = pow_motion*input.y
			
		
		if pos == 0:
			kick_instance.extra_position = Vector2(32*facing, -16)
		else:
			if pos == -1:
				kick_instance.extra_position = Vector2(22*facing, -32)
			elif pos == 1:
				kick_instance.extra_position = Vector2(20*facing,0)
		get_parent().add_child(kick_instance)
		
		
		
		
		if pow_double == true:
			var kick_instance2 = kick_shot.instance()
			kick_instance2.pos = pos
			kick_instance2.facing = facing
			
			if pos == 0:
				kick_instance2.extra_position = Vector2(32*facing, -16)
			else:
				if pos == -1:
					kick_instance2.extra_position = Vector2(22*facing, -32)
				elif pos == 1:
					kick_instance2.extra_position = Vector2(20*facing,0)
			get_parent().add_child(kick_instance2)


func _on_Area_body_entered(body):
	if body.is_in_group("hurtful"):
		if input.y != 0:
			body.ouch(pow_damage,Vector2(200*facing,250*input.y))#damage, knockback
		else:
			body.ouch(pow_damage,Vector2(200*facing,-100))#damage, knockback
		
		
		if !pow_nostop: motion.x /= 10
		
		if !pow_piercing: $Area/Col.set_deferred("disabled",true)

################################################################################





################################################################################

var HP = 150

func ouch(damage,knockback):
	change_state(STATES.OUCH)
	motion = lerp(motion,Vector2(0,0),DEACCEL)
	motion.x += knockback.x
	motion.y += knockback.y
	
	$AniPlay.stop()
	$AniPlay.playback_speed = 1
	$AniPlay.play("ouch")
	
	HP -= damage
	if HP < 1:
		$AniPlay.stop()
		change_state(STATES.NOCLIP)

################################################################################






################################################################################

func is_on_floor_or_wall():
	if is_on_floor(): return true
	elif is_on_wall() && on_tile > 0: return true
	
	return false



func _draw():#speedometer
	var adjust = -Vector2(-OS.window_size.x/3 * 1/Global.zoom,-OS.window_size.y/3 * 1/Global.zoom)
	var pointy
	
#	for n in 180:
#		if n > 0:
#			pointy = Vector2(-100* 1/Global.zoom,0).rotated(n*PI/180) + adjust
#			draw_line(adjust,pointy,Color8(0,0,0),1/Global.zoom)
	
	
	if abs(motion.x) > 790: pointy = Vector2(-100* 1/Global.zoom,0).rotated(PI) + adjust
	else:
		#pointy = Vector2(-100* 1/Global.zoom,0).rotated(abs(motion.x)*0.004) + adjust
		pointy = Vector2(-33.3,0).rotated(abs(motion.x)*0.004) + adjust
	
	$Speedo.position = adjust - Vector2(0,$Speedo.texture.get_height()/2)
	draw_line(adjust,pointy,Color8(168,0,0),1/Global.zoom)
	
	
	
	adjust = -Vector2(OS.window_size.x/3 * 1/Global.zoom,-OS.window_size.y/3 * 1/Global.zoom)
	pointy = Vector2(-33.3,0).rotated(HP*0.0107) + adjust
	
	$Health.position = adjust - Vector2(0,$Health.texture.get_height()/2)
	draw_line(adjust,pointy,Color8(252,84,84),1/Global.zoom)





func noclip():
	$ColPoly.disabled = true
	motion = Vector2(0,0)
	position += input*10
	
	if Input.is_action_just_pressed("bug_noclip"):
		$ColPoly.disabled = false
		change_state(STATES.IDLE)

