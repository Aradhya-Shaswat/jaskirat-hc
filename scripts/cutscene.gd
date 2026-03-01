extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var audio_player = $AudioStreamPlayer

func _ready() -> void:
	if audio_player and audio_player.stream:
		audio_player.play()
		audio_player.finished.connect(_on_audio_finished)
	
	if animation_player:
		animation_player.play("scene")

func _on_audio_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_screen.tscn")
