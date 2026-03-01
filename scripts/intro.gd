extends Node3D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	if animation_player:
		animation_player.play("intro_anim")
		# The user mentioned the animation is 10 seconds long.
		# We'll use a timer to transition to the world scene.
		await get_tree().create_timer(10.0).timeout
		get_tree().change_scene_to_file("res://scenes/world.tscn")
