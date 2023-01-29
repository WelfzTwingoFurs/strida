extends ColorRect

func _ready():
	material = material.duplicate()

var was_milli
var switch = true
var switch2 = true

func _process(_delta):
	if was_milli != OS.get_system_time_msecs():
		was_milli = OS.get_system_time_msecs()
		switch = !switch
	
	if switch:
		switch2 = !switch2
	
	material.set_shader_param("switcher", switch)
	material.set_shader_param("switcher2", switch2)
