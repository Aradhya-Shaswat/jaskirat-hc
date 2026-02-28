extends NavigationRegion3D

func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	# Limit enemies to 3 per scene by removing excess
	if enemies.size() > 3:
		for i in range(3, enemies.size()):
			enemies[i].queue_free()
		enemies.resize(3)
		
	# Scale enemies before baking
	for enemy in enemies:
		var sm = get_node_or_null("/root/SceneManager")
		if sm and sm.current_level > 1:
			# +25% base health per stage
			var health_multiplier = 1.0 + ((sm.current_level - 1) * 0.25)
			enemy.max_health *= health_multiplier
			enemy.current_health = enemy.max_health
			
	# Bake navigation mesh at runtime to ensure all procedural/static objects are included
	bake_navigation_mesh()

func _process(_delta: float) -> void:
	# Check if enemies are cleared and transition scene
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		var sm = get_node_or_null("/root/SceneManager")
		if sm and sm.has_method("load_next_level"):
			sm.load_next_level()
			set_process(false) # Disable process to avoid multiple calls
