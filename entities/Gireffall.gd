extends KinematicBody2D

enum STATES {IDLE,ATTACK}
export(int) var state = STATES.IDLE
var motion = Vector2(0,0)

const GRAVITY = 100

var y = 0
var distanceXY = Vector2(0,0)

var chasing = 0


func change_state(new_state):
	state = new_state

func _physics_process(_delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.y += GRAVITY
	
	if abs(distanceXY.x) < 320 && abs(distanceXY.y) < 170:
		$Vision.cast_to = distanceXY
	
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
	distanceXY = Global.player.position - position
	
	if sign(distanceXY.x) == 1:
		$Sprite.scale.x = 1
		$moving.scale.x = 1
	else:
		$Sprite.scale.x = -1
		$moving.scale.x = -1
	
	$moving/Head.frame = $Sprite.frame+10
	if $Sprite.frame == 2:
		$moving/Head.position = Vector2(-int(y)+18,-18)
		$moving/Polygon2D.rotation_degrees = 90
		$moving/Polygon2D.position = Vector2(56,-28)
	elif $Sprite.frame == 1:
		#$Head.position = Vector2(-int(y)-7,int(y))
		$moving/Head.position = Vector2(-int(y*0.7)+28,int(y*0.7)-35)
		$moving/Polygon2D.rotation_degrees = 45
		$moving/Polygon2D.position = Vector2(29,-65)
	else:
		$moving/Head.position = Vector2(0,int(y) -40)
		$moving/Polygon2D.rotation_degrees = 0
		$moving/Polygon2D.position = Vector2(-20,-65)
		
	
	$moving/Polygon2D.polygon = [Vector2(0,y+40), Vector2(40,y+40), Vector2(40,40), Vector2(0,40)]
	$ColPoly.polygon = [Vector2(0,y), Vector2(6,16), Vector2(0,32), Vector2(-6,16)]
	
	if y > 0:
		y = 0
	elif y < -135:
		y = -135
	
	
	

func idle():
	if chasing > 1:
		y = (lerp(y,-abs(distanceXY.x),0.02))
		#print(y,"    ",-abs(distanceXY.x))
		if y > -abs(distanceXY.x) && abs(distanceXY.x) > 50:
			motion.x = lerp(motion.x,(155+y)*sign(distanceXY.x),0.01)
			$AniPlay.play("walk")
		elif y < -abs(distanceXY.x)/2:
			change_state(STATES.ATTACK)
	else:
		y = (lerp(y,0,0.02))
		motion.x = 0
		$AniPlay.stop()
		$Sprite.frame = 0

func attack():
	motion.x = 0
	$AniPlay.playback_speed = 1
	$AniPlay.play("fall")
	
	if $Sprite.frame == 2:
		$AniPlay.stop()
		if y > -1:
			$AniPlay.play("getup")
			change_state(STATES.IDLE)
		else:
			y += 1
	
