extends StaticBody2D

export var id = 0
export var howmany = 1
export var breakable = false
export var break_after = false

func _ready():
	if breakable:
		$Sprite.frame = id + 10
	else:
		$Sprite.frame = id

func hit(dir):
	if id != 0:
		Global.audio.GETSMALLs()
	else:
		Global.audio.HITHEADs()
	
	if howmany > 0:
		howmany -= 1
		hit_anim(dir)
	else:
		if breakable or (break_after && id == 0):
			boom()
			
		else:
			hit_anim(dir)
			id = 0
			
			if break_after:
				$Sprite.frame = 10
				breakable = true
			else:
				$Sprite.frame = 0
			


func hit_anim(dir):
	if dir == 0:
		$AniPlay.play("hitU")
	elif dir == 1:
		$AniPlay.play("hitR")
	elif dir == -1:
		$AniPlay.play("hitL")
	else:#if dir == 2:
		$AniPlay.play("hitD")


func boom():
	Global.audio.BOOMTINNYs()
	var boom_instance = boom_shot.instance()
	boom_instance.position = position
	get_parent().add_child(boom_instance)
	queue_free()

const boom_shot = preload("res://entities/Boom.tscn")
