extends Node

var current_level: int = 1
var player_health: float = 100.0
var weapon_powers: Array[float] = [100.0, 100.0]

const LEVELS = [
	"res://scenes/world.tscn",
	"res://scenes/scene_2.tscn",
	"res://scenes/scene_3.tscn",
	"res://scenes/scene_4.tscn",
    "res://scenes/scene_5.tscn"
]

func load_next_level() -> void:
	current_level += 1
	if current_level > LEVELS.size():
		get_tree().change_scene_to_file("res://scenes/cutscene.tscn")
	else:
		call_deferred("_deferred_load")

func _deferred_load() -> void:

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player_health = player.max_health
		for i in range(player.weapons.size()):
			weapon_powers[i] = player.weapons[i].max_power

	get_tree().change_scene_to_file(LEVELS[current_level - 1])
