extends Control

var click_player: AudioStreamPlayer

func _ready() -> void:
	click_player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.1
	click_player.stream = stream
	click_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(click_player)

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

func _on_back_pressed() -> void:
	play_click_sound()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/menu_screen.tscn")
