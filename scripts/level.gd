extends NavigationRegion3D


var _initial_enemy_count: int = 0

func _compute_initial_enemies() -> void:
	var total_enemies = get_tree().get_nodes_in_group("enemy").size()
	_initial_enemy_count = mini(total_enemies, 3)

func _update_ui_progress() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var sm = get_node_or_null("/root/SceneManager")
	var current_stage = sm.current_level if sm else 1
	
	if player and player.ui:
		var current_enemies = get_tree().get_nodes_in_group("enemy").size()
		# If the tree hasn't processed queue_free, cap current_enemies to _initial
		current_enemies = mini(current_enemies, _initial_enemy_count)
		
		var progress = 0.0
		if _initial_enemy_count > 0:
			progress = 1.0 - (float(current_enemies) / _initial_enemy_count)
		player.ui.update_stage_progress(current_stage, progress)

func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	if enemies.size() > 3:
		for i in range(3, enemies.size()):
			enemies[i].queue_free()
		enemies.resize(3)
	
	_compute_initial_enemies()

	for enemy in enemies:
		var sm = get_node_or_null("/root/SceneManager")
		if sm and sm.current_level > 1:

			var health_multiplier = 1.0 + ((sm.current_level - 1) * 0.25)
			enemy.max_health *= health_multiplier
			enemy.current_health = enemy.max_health

	bake_navigation_mesh()
	_update_ui_progress()

func _process(_delta: float) -> void:

	var enemies = get_tree().get_nodes_in_group("enemy")
	_update_ui_progress()
	if enemies.size() == 0:
		var sm = get_node_or_null("/root/SceneManager")
		if sm and sm.has_method("load_next_level"):
			sm.load_next_level()
			set_process(false)
