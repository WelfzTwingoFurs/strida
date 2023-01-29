extends KinematicBody2D

enum STATES {IDLE,ATTACK}
export(int) var state = STATES.IDLE
var motion = Vector2(0,0)

const GRAVITY = 100

var y = 0
var dist_player = Vector2(INF,INF)
var dist_camera = Vector2(INF,INF)

var chasing = 0

func change_state(new_state):
	state = new_state

func _physics_process(_delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.y += GRAVITY
	
	if abs(dist_camera.x) < 320 && abs(dist_camera.y) < 170:
		$Vision.cast_to = dist_player
	
	if $Vision.is_colliding() && $Vision.get_collider().is_in_group("player"):
		chasing = 100 #we got a hit, reset timer
	else:
		chasing -= 1
	

func _process(_delta):
	match state:
		STATES.IDLE:
			idle()
		STATES.ATTACK:
			attack()
	dist_player = Global.player.position - position
	dist_camera = Global.player.camerapos - position
	
	if chasing > 1:
		if sign(dist_player.x) == 1:
			$Sprite.scale.x = 1
			$Area.scale.x = 1
			$moving.scale.x = 1
			$Checker.position.x = 8
		else:
			$Sprite.scale.x = -1
			$Area.scale.x = -1
			$moving.scale.x = -1
			$Checker.position.x = -8
	
	$moving/Head.frame = $Sprite.frame+10
	if $Sprite.frame == 2:
		$Checker.cast_to = Vector2(0,y*-$Sprite.scale.x)
		$moving/Head.position = Vector2(-int(y)+18,-18)
		$moving/Polygon2D.rotation_degrees = 90
		$moving/Polygon2D.position = Vector2(56,-28)
		$Area/Col.shape.points = [Vector2(8,16), Vector2($moving/Head.position.x,$moving/Head.position.y+45),Vector2(-int(y*0.7),int(y*0.7))]
		$Checker.position.y = -5
		$ColPoly.polygon = [Vector2(1,16), Vector2(0,32), Vector2(-1,16)]
		
		#if $Checker.is_colliding():
		#	y = abs($Checker.get_collision_point().x - position.x)/2 -40
		
	elif $Sprite.frame == 1:
		#$Head.position = Vector2(-int(y)-7,int(y))
		$moving/Head.position = Vector2(-int(y*0.7)+28,int(y*0.7)-35)
		$moving/Polygon2D.rotation_degrees = 45
		$moving/Polygon2D.position = Vector2(29,-65)
		$Area/Col.shape.points = [Vector2(8,16), Vector2($moving/Head.position.x,$moving/Head.position.y+45), Vector2(0,y)]
	else:
		#$Checker.cast_to = Vector2(abs(dist_player.x),0)
		$Checker.position.y = -27
		$moving/Head.position = Vector2(0,int(y) -40)
		$moving/Polygon2D.rotation_degrees = 0
		$moving/Polygon2D.position = Vector2(-20,-65)
		$Area/Col.shape.points = [Vector2(8,16), Vector2(0, y), Vector2(8,y)]
		$ColPoly.polygon = [Vector2($moving/Head.position.x*$Sprite.scale.x,$moving/Head.position.y+45), Vector2(1,16), Vector2(0,32), Vector2(-1,16)]
		
		if $Checker.is_colliding():
			$Checker.cast_to = Vector2(abs(y)+10, 0)
		#	y = abs($Checker.get_collision_point().x - position.x)/2 -40
		else:
			$Checker.cast_to = Vector2(abs(dist_player.x),0)
	
	$moving/Polygon2D.polygon = [Vector2(0,y+40), Vector2(40,y+40), Vector2(40,40), Vector2(0,40)]
	$HeadPoly.position = Vector2($moving/Head.position.x*$Sprite.scale.x,$moving/Head.position.y)
	
	if y > 0:
		y = 0
	elif y < -135:
		y = -135
	
	

	
	

func idle():
	if chasing > 1:
		if !$Checker.is_colliding():
			y = (lerp(y,-abs(dist_player.x),0.02))
		else:
			y += 1
		
		#print(y,"    ",-abs(dist_player.x))
		if y > -abs(dist_player.x) && abs(dist_player.x) > y:
			motion.x = lerp(motion.x,(155+y)*sign(dist_player.x),0.01)
			$AniPlay.play("walk")
		elif y < -abs(dist_player.x)/2:
			#if $Vision.is_colliding() && $Vision.get_collider().is_in_group("player"):
			#if y < -abs(dist_player.x)/2:
			change_state(STATES.ATTACK)
	else:
		y = (lerp(y,0,0.02))
		motion.x = 0
		$AniPlay.stop()
		$Sprite.frame = 0

func attack():
	motion.x = 0
	$AniPlay.playback_speed = 1
	
	if $Sprite.frame == 2:
		$AniPlay.play("fixconditions") #oh how I love that jank :)
		if y > -1:
			$AniPlay.play("getup")
			change_state(STATES.IDLE)
		else:
			y += 1
	
	else:
		$AniPlay.play("fall")


func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		body.ouch(35, Vector2(120*$Sprite.scale.x,-100), 0.8)
		
		#motion += Vector2(500*-facing,-100)
