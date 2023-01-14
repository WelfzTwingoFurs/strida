extends KinematicBody2D

var y = 0

func _process(delta):
	$Head.frame = $Sprite.frame+10
	if $Sprite.frame == 2:
		$Head.position = Vector2(-int(y)+18,-18)
		$Polygon2D.rotation_degrees = 90
		$Polygon2D.position = Vector2(56,-28)
	elif $Sprite.frame == 1:
		$Head.position = Vector2(-int(y)-7,int(y))
		$Polygon2D.rotation_degrees = 45
		$Polygon2D.position = Vector2(29,-65)
	else:
		$Head.position = Vector2(0,int(y) -40)
		$Polygon2D.rotation_degrees = 0
		$Polygon2D.position = Vector2(-20,-65)
	
	
	$Polygon2D.polygon = [Vector2(0,y+40), Vector2(40,y+40), Vector2(40,40), Vector2(0,40)]
	$ColPoly.polygon = [Vector2(0,y), Vector2(6,16), Vector2(0,32), Vector2(-6,16)]
	
	if y > 0:
		y = 0
	y = (lerp(y,Global.player.position.y-position.y,0.02))

