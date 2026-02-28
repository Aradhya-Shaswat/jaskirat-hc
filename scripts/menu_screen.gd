extends Control

func _ready() -> void:
	$VBoxContainer/Button.pressed.connect(_on_button_pressed)
	$VBoxContainer/Button2.pressed.connect(_on_button2_pressed)
	$VBoxContainer/Button3.pressed.connect(_on_button3_pressed)
	$VBoxContainer/Button4.pressed.connect(_on_button4_pressed)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_button2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scene2.tscn")

func _on_button3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scene3.tscn")

func _on_button4_pressed() -> void:
	get_tree().quit()
