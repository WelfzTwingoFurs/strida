extends Label

export var type = 0
export var mode = 0

func _ready():
	visible = true

func _process(_delta):
	if Input.is_action_just_pressed("bug_console"):
		visible = !visible
	
	if visible:
		if type == 0:
			margin_top    = (OS.window_size.y/3 * 1/Global.zoom)
			margin_left   = (OS.window_size.x/3 * 1/Global.zoom)
			margin_bottom = margin_top + 10
			margin_right = margin_left + 10
			text = str(int(abs(Global.player.motion.x)))
		
		elif type == 1:
			margin_top    = (OS.window_size.y/3 * 1/Global.zoom)
			margin_left   = (-OS.window_size.x/3 * 1/Global.zoom) - 25
			margin_bottom = margin_top + 10
			margin_right = margin_left + 10
			text = str(Global.player.HP)
	
		elif type == 2:
			margin_top    = (-OS.window_size.y/2 * 1/Global.zoom)
			margin_left   = (-OS.window_size.x/2 * 1/Global.zoom)
			margin_bottom = margin_top + 10
			margin_right = margin_left + 10
			
			if Input.is_action_just_pressed("con_mode"):
				mode += 1
				if mode > 3:
					mode = 0
			
			if mode == 0:
				text = str("Press ['] for help... ",Engine.get_frames_per_second())
			elif mode == 1:
				text = str("CONTROLS:\n move-[WASD],\n jump-[UP],\n kick-[RIGHT];\nBUG\nnoclip & heal[C],\n text toggle[ESC],\n next page['];\nMOVES\n move+kick,\n head-butt,\n freeze-stomp.")
			elif mode == 2:
				text = str("RESOLUTION:\n readjust [BCKSPC],\n zoom plus[+],\n zoom minus[-],\n screen/2[F1],\n screen*2[F2];\nSPEED:\n -[F9], +[F10], 1[F11], 0[F12].\nSCENE:\n reset [F5].")
			elif mode == 3:
				text = str(
					"PLAYER\n","state:",Global.player.state," input:",Global.player.input," facing:",Global.player.facing," on_tile:",Global.player.on_tile," HP:",Global.player.HP,
					"\nwas_on_floor:",Global.player.was_on_floor," jump_check:",Global.player.jump_check," elevator:",Global.player.elevator,
					"\nPOW\nwave:",Global.player.pow_wave,"\nmotion:",Global.player.pow_motion,"\nrepeat:",Global.player.pow_repeat,"\nscale:",Global.player.pow_scale,
					"\ndouble:",Global.player.pow_double,"\npiercing:",Global.player.pow_piercing,"\npow_nostop:",Global.player.pow_nostop,"\ndamage:",Global.player.pow_damage,
					"\nkicktime:",Global.player.pow_kicktime,"\nwavetime:",Global.player.pow_wavetime,"\nfreezetime:",Global.player.pow_freezetime,"\nstuntime:",Global.player.pow_kickstuntime,
					"\nGLOBAL\nzoom:",Global.zoom
					)
