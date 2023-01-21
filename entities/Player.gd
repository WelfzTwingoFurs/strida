extends KinematicBody2D

enum STATES {IDLE,ATTACK,NOCLIP,OUCH}
export(int) var state = STATES.IDLE
var motion = Vector2(0,0)

var input = Vector2(0,0)
var facing = 1

var on_tile = 0
var was_tile = -1

const TOP_SPEED = 175
const ACCEL = 0.5
const DEACCEL = 0.25
const JUMP = 300
const GRAVITY = 10

func change_state(new_state):
	state = new_state

func _ready():
	Global.player = self
	$Speedo.visible = true
	$Health.visible = true

func _process(_delta):
	if $Sprite.frame == 30 or state == 2 or $AniPlay.current_animation == "freeze":# or $Sprite.frame == 31:
		$Sprite.modulate.a = 0 if Engine.get_frames_drawn() % 2 == 0 else 1
	else:
		$Sprite.modulate.a = 1.0

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
	
	if elevator == null:# or (elevator != null && input.y == 0):
		motion.y += GRAVITY
	else:
		on_tile = 1
		motion.y = elevator.motion.y
		position.y = elevator.position.y
	
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
	
	
	on_tile = Global.TileZone.get_cellv( Global.TileZone.world_to_map(position) )
	

	
	#CHANGED x=8 TO x=6, y HAS BECOME INCORRECT, HOWEVER LESS 'STICKY' 'STIFFY' 'JANKY' SO KEEP IT
	if on_tile < 1: #straight floor or air
		$ColPoly.polygon =[Vector2(0,0), Vector2(6,16), Vector2(6,32), Vector2(-6,32), Vector2(-6,16)]
		if is_on_floor(): #Only reset after landing
			$Sprite.position = Vector2(0,-20)
	
	else:#if on_tile > 1:
		$ColPoly.polygon = [Vector2(0,0), Vector2(6,16), Vector2(0,32), Vector2(-6,16)]
		if on_tile == 1: #1x1
			$Sprite.position = Vector2(6*$ColPoly.scale.x,-20)
	
		elif on_tile == 2: #2x1
			$Sprite.position = Vector2(7*$ColPoly.scale.x,-20)
	
		elif on_tile == 3: #1x2
			$Sprite.position = Vector2(4*$ColPoly.scale.x, -20)
	
	if was_tile != on_tile:
		ani_walkslope()
		was_tile = on_tile
	
	
	if Global.TileZone.is_cell_x_flipped( Global.TileZone.world_to_map(position).x, Global.TileZone.world_to_map(position).y ):
		$ColPoly.scale.x = -1
	else:
		$ColPoly.scale.x = 1
	
	########################################################################
	
	if is_on_floor() && was_on_floor:
		if on_tile != 4:
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



func audio_step():
	if is_on_floor_or_wall():
		Global.audio.STEPs()

################################################################################

var elevator = null

func idle():
	if Input.is_action_just_pressed("bug_noclip"): change_state(STATES.NOCLIP)
	
	if Input.is_action_just_pressed("ply_attack"):
		change_state(STATES.ATTACK)
	
	
	if input.x != 0:
		motion.x += input.x#running
		if $Sprite.frame == 6: ani_walk()
		
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
		$Step/Col.disabled = true
		$Head/Col.disabled = true
		
		if Input.is_action_just_pressed("ply_jump") && (on_tile != 3):#can't jump on a slope too steep
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
				if $AniPlay.current_animation != "fakekickup" && $AniPlay.current_animation != "fakekickdown":
					$AniPlay.stop()
					if sign(motion.y) == 1:
						#if (on_tile == 4 && input.x != facing) or on_tile != 4:
						if elevator == null && ($Sprite.frame < 20 or $Sprite.frame > 25): $Sprite.frame = 6 
						else:
							if int(motion.x) == 0:
								if input.y == 0: $Sprite.frame = 0
								else: 
									if facing != sign(elevator.position.x - position.x): $Sprite.frame = 37
									else: $Sprite.frame = 38
								
							else: $Sprite.frame = 4
						#else:
						#	$AniPlay.play("walkstairs")
					else:
						if elevator == null: $Sprite.frame = 5
						else:
							if int(motion.x) == 0:
								if input.y == 0: $Sprite.frame = 0
								else:
									if facing != sign(elevator.position.x - position.x): $Sprite.frame = 36
									else: $Sprite.frame = 39
									
								
							else: $Sprite.frame = 4
				#elif Input.is_action_pressed("ply_jump"):
				#	$AniPlay.stop()
				#	$Sprite.frame = 5 
			
			
			
			
		#rygar step, mario's head
		if sign(motion.y) == 1:
			$Head/Col.disabled = true
			$Step/Col.disabled = false
		else:
			$Head/Col.disabled = false
			$Step/Col.disabled = true
	




func ani_walk():#Use this function as we have varying animations
	if !$AniPlay.current_animation == "freeze":
		if on_tile < 1:
			$AniPlay.play("walk")
		elif on_tile == 1:
			$AniPlay.play("walk1")
		elif on_tile == 2:
			$AniPlay.play("walk2")
		elif on_tile == 3:
			$AniPlay.play("walk3")

func ani_walkslope():#Use this function as we have varying animations
	if !$AniPlay.current_animation == "freeze":
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
export var pow_kicktime = 1
export var pow_wavetime = 1
export var pow_freezetime = 1
export var pow_kickstuntime = 1

func kick():
	if !is_on_floor():
		if sign(motion.y) == 1:
			$Head/Col.disabled = true
			$Step/Col.disabled = false
		else:
			$Head/Col.disabled = false
			$Step/Col.disabled = true
		
	#$AniPlay.playback_speed = 1
	#don't re-do animation if only input.y is changed
	if $AniPlay.current_animation != "kickhigh" && $AniPlay.current_animation != "kickmid" && $AniPlay.current_animation != "kicklow" && $AniPlay.current_animation != "kickhighair" && $AniPlay.current_animation != "kickmidair" && $AniPlay.current_animation != "kicklowair":
		kick_anim()
	
	if is_on_floor():
		if Input.is_action_just_pressed("ply_jump") && (on_tile != 3):#can't jump on a slope too steep
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
	$AniPlay.playback_speed = pow_kicktime
	
	motion.x += facing*10 + input.x*10
	#if is_on_floor():
	if input.y == -1:
		$Area/Col.position = Vector2(11*facing,-32)
		if is_on_floor() or elevator != null: $AniPlay.play("kickhigh")
		else: $AniPlay.play("kickhighair")
	elif input.y == 0:
		$Area/Col.position = Vector2(16*facing,-16)
		if is_on_floor() or elevator != null: $AniPlay.play("kickmid")
		else: $AniPlay.play("kickmidair")
	elif input.y == 1:
		$Area/Col.position = Vector2(11*facing,0)
		if is_on_floor() or elevator != null: $AniPlay.play("kicklow")
		else: $AniPlay.play("kicklowair")
#	else:
#		if input.y == -1:
#			$AniPlay.play("kickhighair")
#		elif input.y == 0:
#			$AniPlay.play("kickmidair")
#		elif input.y == 1:
#			$AniPlay.play("kicklowair")


const kick_shot = preload("res://entities/PlayerKick.tscn")

func kick_shoot(pos):
	if pow_wave:
		pos = input.y
		Global.audio.SHOOTs()
		var kick_instance = kick_shot.instance()
		kick_instance.pos = pos
		kick_instance.facing = facing
		kick_instance.pierce = pow_piercing
		kick_instance.wavetime = pow_wavetime
		kick_instance.freezetime = pow_freezetime
		
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




################################################################################

func _on_Area_body_entered(body):
	if body.is_in_group("hurtful") && body.HP > 0:
		if input.y != 0:
			if input.y == -1:
				body.ouch(pow_damage,Vector2(50*facing,300*input.y),pow_kickstuntime)#damage, knockback, aniplay speed
			else:
				body.ouch(pow_damage,Vector2(300*facing,-50),pow_kickstuntime)#damage, knockback, aniplay speed
		else:
			body.ouch(pow_damage,Vector2(200*facing,-100),pow_kickstuntime)#damage, knockback, aniplay speed
		
		
		if !pow_nostop: motion.x /= 10
		
		if !pow_piercing: $Area/Col.set_deferred("disabled",true)
	
	elif body.is_in_group("headable"): #hit blocks
		if body.position.y > position.y && input.y == 1:
			body.hit(2)
		elif body.position.y < position.y && input.y == -1:
			body.hit(0)
		else:
			body.hit(facing)

################################################################################

func _on_Step_body_entered(body): #step
	if position.y < body.position.y: 
		if body.is_in_group("freezeful") && body.state != 3 && body.position.y > position.y && sign(motion.y) == 1: #step on enemies like Rygar
			motion.y = -JUMP#-abs(motion.y)/2
			body.wave_freezetime = pow_freezetime
			body.freeze(false)
			if state == 0:
				$AniPlay.play("fakekickdown")
		
		elif body.is_in_group("headable") && (body.breakable == true && body.howmany == 0): #step-kill blocks when standing on it
			motion.y = 0
			body.hit(2)
			if state == 0:
				$AniPlay.play("fakekickdown")

################################################################################

func _on_Head_body_entered(body): #hit blocks like mario
	if body.is_in_group("headable"):
		motion.y = 0
		body.hit(0)
		$AniPlay.play("fakekickup")
	
	elif body.is_in_group("hurtful") && (body.position.y < position.y) && sign(motion.y) == -1 && body.HP > 0:
		motion.y = 0
		body.ouch(pow_damage,Vector2(facing,-200), pow_kickstuntime)#damage, knockback
		$AniPlay.play("fakekickup")

################################################################################






################################################################################

var HP = 150

func ouch(damage,knockback,timer):
	if $AniPlay.current_animation != "ouch":
		$Area/Col.set_deferred("disabled", true)
		$Step/Col.set_deferred("disabled", true)
		$Head/Col.set_deferred("disabled", true)
		change_state(STATES.OUCH)
		#motion = lerp(motion,Vector2(0,0),DEACCEL)
		motion.x += knockback.x
		motion.y += knockback.y
		
		$AniPlay.stop()
		$AniPlay.playback_speed = timer
		
		if damage > 0:
			$AniPlay.play("ouch")
			HP -= damage
		else:
			$AniPlay.play("ouchnot")
		
		if HP < 1:
			Global.audio.GETBIGs()
			$AniPlay.stop()
			change_state(STATES.NOCLIP)

################################################################################

func freeze(timer):
	if $AniPlay.current_animation != "freeze":
		$Area/Col.set_deferred("disabled", true)
		$Step/Col.set_deferred("disabled", true)
		$Head/Col.set_deferred("disabled", true)
		Global.audio.BEEPs()
		change_state(STATES.OUCH)
		motion /= 3
		$AniPlay.stop()
		$AniPlay.playback_speed = timer
		$AniPlay.play("freeze")












func is_on_floor_or_wall():
	if is_on_floor(): return true
	elif is_on_wall() && on_tile > 0: return true
	
	return false

################################################################################

func _draw():#speedometer
	var adjust = -Vector2(-OS.window_size.x/3 * 1/Global.zoom,-OS.window_size.y/3 * 1/Global.zoom)
	var pointy
	
#	for n in 180:
#		if n > 0:
#			pointy = Vector2(-100* 1/Global.zoom,0).rotated(n*PI/180) + adjust
#			draw_line(adjust,pointy,Color8(0,0,0),1/Global.zoom)
	
	
	if abs(motion.x) > 1500: pointy = Vector2(-33.3,0).rotated(1500*0.00211) + adjust
	else:
		#pointy = Vector2(-100* 1/Global.zoom,0).rotated(abs(motion.x)*0.004) + adjust
		pointy = Vector2(-33.3,0).rotated(abs(motion.x)*0.002) + adjust
	
	$Speedo.position = adjust - Vector2(0,$Speedo.texture.get_height()/2)
	draw_line(adjust,pointy,Color8(168,0,0),1/Global.zoom)
	
	
	
	adjust = -Vector2(OS.window_size.x/3 * 1/Global.zoom,-OS.window_size.y/3 * 1/Global.zoom)
	pointy = Vector2(-33.3,0).rotated(HP*0.0209) + adjust
	
	$Health.position = adjust - Vector2(0,$Health.texture.get_height()/2)
	draw_line(adjust,pointy,Color8(252,84,84),1/Global.zoom)
	
	
	
	#print(get_viewport().size)
	#(640, 339)
	
	draw_line(Vector2(-320, -170), Vector2(320, -170), Color(1,1,1), 1) #¨
	draw_line(Vector2(-320, 170), Vector2(320, 170), Color(1,1,1), 1) #_
	
	draw_line(Vector2(-320, 170), Vector2(-320, -170), Color(1,1,1), 1) #|_
	draw_line(Vector2(321, 170), Vector2(321, -170), Color(1,1,1), 1) #_|


################################################################################


func noclip():
	$AniPlay.stop()
	HP = 150
	$Step/Col.disabled = true
	$ColPoly.disabled = true
	$Area/Col.disabled = true
	motion = Vector2(0,0)
	position += input*10
	
	if Input.is_action_just_pressed("bug_noclip"):
		$ColPoly.disabled = false
		change_state(STATES.IDLE)



