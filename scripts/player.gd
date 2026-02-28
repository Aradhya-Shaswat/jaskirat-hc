extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const SPRINT_MULTIPLIER = 1.8
const CROUCH_MULTIPLIER = 0.5
const CROUCH_HEIGHT = 0.5

@export
var voxel_terrain: VoxelTerrain

@onready
var voxel_tool: VoxelTool = voxel_terrain.get_voxel_tool()

var is_crouching := false
var is_sprinting := false
var is_firing := false

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var head: Node3D = $head
@onready var camera: Camera3D = $head/Camera3D
@onready var ui = $UI

# Health Mechanics
@export var max_health: float = 100.0
var current_health: float

var spawn_position: Vector3

# Weapons
var weapons: Array[Weapon] = []
var active_weapon_index = 0

var standing_height: float
var crouching_height: float

func _ready() -> void:
	standing_height = collision_shape.shape.height
	crouching_height = standing_height * CROUCH_HEIGHT
	
	spawn_position = global_position
	current_health = max_health
	
	_setup_weapons()
	
	if SceneManager and SceneManager.current_level > 1:
		current_health = SceneManager.player_health
		for i in range(weapons.size()):
			weapons[i].current_power = SceneManager.weapon_powers[i]
	
	# Initial UI update
	if ui:
		ui.update_health(current_health, max_health)
		ui.update_active_weapon(weapons[active_weapon_index])
		if SceneManager:
			ui.update_stage(SceneManager.current_level)

func _setup_weapons() -> void:
	if not InputMap.has_action("slot_1"):
		InputMap.add_action("slot_1")
		var key1 = InputEventKey.new()
		key1.keycode = KEY_1
		InputMap.action_add_event("slot_1", key1)
	if not InputMap.has_action("slot_2"):
		InputMap.add_action("slot_2")
		var key2 = InputEventKey.new()
		key2.keycode = KEY_2
		InputMap.action_add_event("slot_2", key2)

	if not InputMap.has_action("weapon_next"):
		InputMap.add_action("weapon_next")
		var m_up = InputEventMouseButton.new()
		m_up.button_index = MOUSE_BUTTON_WHEEL_UP
		InputMap.action_add_event("weapon_next", m_up)
		
	if not InputMap.has_action("weapon_prev"):
		InputMap.add_action("weapon_prev")
		var m_down = InputEventMouseButton.new()
		m_down.button_index = MOUSE_BUTTON_WHEEL_DOWN
		InputMap.action_add_event("weapon_prev", m_down)

	# Add FireWeapon and PoisonWeapon
	var fire_wep = FireWeapon.new()
	var poison_wep = PoisonWeapon.new()
	camera.add_child(fire_wep)
	camera.add_child(poison_wep)
	weapons.append(fire_wep)
	weapons.append(poison_wep)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	is_sprinting = Input.is_action_pressed("sprint") and not is_crouching

	var wants_to_crouch := Input.is_action_pressed("crouch")
	if wants_to_crouch and not is_crouching:
		_set_crouch(true)
	elif not wants_to_crouch and is_crouching:
		if _can_stand_up():
			_set_crouch(false)

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if is_crouching and _can_stand_up():
			_set_crouch(false)
		else:
			velocity.y = JUMP_VELOCITY
			
	# Switch Weapons
	if Input.is_action_just_pressed("slot_1") and weapons.size() > 0:
		_switch_weapon(0)
	elif Input.is_action_just_pressed("slot_2") and weapons.size() > 1:
		_switch_weapon(1)
	elif Input.is_action_just_pressed("weapon_next") and weapons.size() > 1:
		var next_idx = (active_weapon_index + 1) % weapons.size()
		_switch_weapon(next_idx)
	elif Input.is_action_just_pressed("weapon_prev") and weapons.size() > 1:
		var prev_idx = (active_weapon_index - 1 + weapons.size()) % weapons.size()
		_switch_weapon(prev_idx)
		
	# Process active weapon regeneration or firing
	for i in range(weapons.size()):
		var wep = weapons[i]
		if i == active_weapon_index and Input.is_action_pressed('dig'):
			wep.fire(delta)
		else:
			wep.stop_fire()
			wep.regenerate_power(delta)
			
	if ui:
		var active_wep = weapons[active_weapon_index]
		ui.update_active_weapon(active_wep)

	# Movement speed based on state
	var current_speed := SPEED
	if is_sprinting:
		current_speed *= SPRINT_MULTIPLIER
	elif is_crouching:
		current_speed *= CROUCH_MULTIPLIER

	# Input direction
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func _set_crouch(crouching: bool) -> void:
	is_crouching = crouching
	collision_shape.shape.height = crouching_height if crouching else standing_height

func _can_stand_up() -> bool:
	# Cast a ray upward to check for overhead obstacles
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.UP * standing_height,
		collision_mask
	)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	return result.is_empty()

func _switch_weapon(index: int) -> void:
	if active_weapon_index != index:
		weapons[active_weapon_index].stop_fire()
		active_weapon_index = index
		if ui:
			ui.update_active_weapon(weapons[active_weapon_index])

func take_damage(amount: float) -> void:
	current_health -= amount
	current_health = max(current_health, 0)
	
	if ui:
		ui.update_health(current_health, max_health)
		
	if current_health <= 0:
		die()

func die() -> void:
	# Respawn logic
	global_position = spawn_position
	current_health = max_health
	for wep in weapons:
		wep.current_power = wep.max_power
		wep.stop_fire()
	
	if ui:
		ui.update_health(current_health, max_health)
		ui.update_active_weapon(weapons[active_weapon_index])
