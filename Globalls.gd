extends Node
#printraw (PoolByteArray([0x07]).get_string_from_ascii())

var TileZone
var player
var audio
var camera = Camera2D

var step = 0
var zoom = 2

var was_pos

func _process(_delta):
	if step == 0: # Viewport, Keep -- Window size = monitor, image stretches, keep aspect-ratio
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(OS.window_size.x, OS.window_size.y))
		was_pos = OS.get_window_position()
		step = 1
	
	elif step == 1: # Disabled, Ignore -- Window size /= zoom (zoom part 1), image doesn't stretch, keep vertical aspect-ratio
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(OS.window_size.x, OS.window_size.y))
		OS.window_size /= zoom 
		
		step = 2
	
	elif step == 2: # Viewport, Keep --  Window size *= zoom (zoom OK), image stretches, keep aspect-ratio
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(OS.window_size.x, OS.window_size.y))
		OS.window_size *= zoom 
		OS.window_position = was_pos
		
		step = -1
	
	if Input.is_action_just_pressed("cam_minus") && zoom > 1:
		zoom -= 1
		step = 0
	
	elif Input.is_action_just_pressed("cam_plus"):
		zoom += 1
		if zoom == 0:
			zoom = 1
		step = 0
	



	if Input.is_action_just_pressed("res_half"):
		OS.center_window()
		OS.window_size /= 2
		OS.center_window()
		#zoom -= 1
		#if zoom == 0:
		#	zoom = 1
		step = 0
	
	elif Input.is_action_just_pressed("res_double"):
		OS.center_window()
		OS.window_size *= 2
		OS.center_window()
		#zoom += 1
		step = 0












	
	elif Input.is_action_pressed("bug_resreset"):
		step = 0
	
	
	if Input.is_action_just_pressed("bug_reset"):#F5
		Engine.time_scale = 1
		var thefunctionreloadcurrentscenereturnsavaluebutthisvalueisneverused = get_tree()
		thefunctionreloadcurrentscenereturnsavaluebutthisvalueisneverused.reload_current_scene()
	
	
	if Input.is_action_pressed("bug_speeddown") && Engine.time_scale > 0.1:
		Engine.time_scale -= 0.1
		
	elif Input.is_action_pressed("bug_speedup"):
		Engine.time_scale += 0.1
		
	elif Input.is_action_just_pressed("bug_speedone"):
		Engine.time_scale = 1
		
	elif Input.is_action_just_pressed("bug_speedzero"):
		Engine.time_scale = 0
		
	
	
