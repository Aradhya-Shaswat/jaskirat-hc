extends CanvasLayer

var click_player: AudioStreamPlayer

func _ready() -> void:
	visible = false

	click_player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.1
	click_player.stream = stream

	click_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(click_player)

	if not InputMap.has_action("ui_cancel"):
		InputMap.add_action("ui_cancel")
		var escape_key = InputEventKey.new()
		escape_key.keycode = KEY_ESCAPE
		InputMap.action_add_event("ui_cancel", escape_key)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			_resume()
		else:
			_pause()

func play_click_sound() -> void:
	click_player.play()
	if click_player.has_stream_playback():
		var playback = click_player.get_stream_playback()
		var phase = 0.0
		var increment = 600.0 / 22050.0
		var frames_available = playback.get_frames_available()
		for i in range(frames_available):
			var sample = sin(phase * TAU) * 0.5 * exp(-i / 500.0)
			playback.push_frame(Vector2(sample, sample))
			phase = fmod(phase + increment, 1.0)

func _pause() -> void:
	get_tree().paused = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _resume() -> void:
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed() -> void:
	play_click_sound()
	_resume()

func _on_quit_pressed() -> void:
	play_click_sound()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
