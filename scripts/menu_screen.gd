extends Control

var click_player: AudioStreamPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	click_player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.1
	click_player.stream = stream
	add_child(click_player)

	var btn1 = get_node_or_null("VBoxContainer/Button")
	if btn1: btn1.pressed.connect(_on_button_pressed)
	
	var btn2 = get_node_or_null("VBoxContainer/Button2")
	if btn2: btn2.pressed.connect(_on_button2_pressed)
	
	var btn3 = get_node_or_null("VBoxContainer/Button3")
	if btn3: btn3.pressed.connect(_on_story_pressed)
	
	var btn4 = get_node_or_null("VBoxContainer/Button4")
	if btn4: btn4.pressed.connect(_on_button4_pressed)
	
	var btn67 = get_node_or_null("VBoxContainer/Button67")
	if btn67: btn67.pressed.connect(_on_button67_pressed)

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

func _on_button_pressed() -> void:
	play_click_sound()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

func _on_button2_pressed() -> void:
	play_click_sound()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/options.tscn")

func _on_story_pressed() -> void:
	play_click_sound()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/story_screen.tscn")

func _on_button4_pressed() -> void:
	play_click_sound()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()	

func _on_button67_pressed() -> void:
	play_click_sound()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/menu_screen.tscn")
