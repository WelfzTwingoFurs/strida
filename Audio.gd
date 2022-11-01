extends AudioStreamPlayer2D

var which

const STEP1 = preload("res://SFX/step1.wav")
const STEP2 = preload("res://SFX/step2.wav")

func STEPs():
	which = (randi() % 2)
	if which == 0:
		set_stream(STEP1)
	if which == 1:
		set_stream(STEP2)
	play()


const JUMP = preload("res://SFX/jump.wav")

func JUMPs():
	set_stream(JUMP)
	play()


const JUMPLAND = preload("res://SFX/jumpland.wav")

func JUMPLANDs():
	set_stream(JUMPLAND)
	play()


const SHOOT = preload("res://SFX/shoot.wav")

func SHOOTs():
	set_stream(SHOOT)
	play()

