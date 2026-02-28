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

# Fire Power Mechanics
@export var max_fire_power: float = 100.0
var current_fire_power: float
var fire_depletion_rate: float = 25.0 # Depletes 100 in 4 seconds
var fire_regen_rate: float = 100.0 / 15.0 # Regens exactly 100 over 15 seconds
# Fire Weapon Mechanics
var fire_particles: GPUParticles3D
var fire_area: Area3D
var fire_collision: CollisionShape3D

const FIRE_DAMAGE := 20.0 # Damage per second
const FIRE_RANGE := 10.0

var standing_height: float
var crouching_height: float

func _ready() -> void:
	standing_height = collision_shape.shape.height
	crouching_height = standing_height * CROUCH_HEIGHT
	
	spawn_position = global_position
	current_health = max_health
	current_fire_power = max_fire_power
	
	# Initial UI update
	if ui:
		ui.update_health(current_health, max_health)
		ui.update_fire_power(current_fire_power, max_fire_power)
	
	_setup_fire_mechanics()

func _setup_fire_mechanics() -> void:
	# 1. Setup Area3D for collision detection
	fire_area = Area3D.new()
	fire_area.collision_layer = 0 # Doesn't need to be on a layer, just scans
	fire_area.collision_mask = 2 # Assuming enemies are on layer 2
	camera.add_child(fire_area)
	
	# Create a capsule or box shape for the fire hit area
	fire_collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1.5, 1.5, FIRE_RANGE)
	fire_collision.shape = shape
	fire_collision.position = Vector3(0, 0, -FIRE_RANGE / 2.0)
	fire_area.add_child(fire_collision)
	
	# 2. Setup Particles
	var fire_scene = load("res://scenes/particles/fire.tscn")
	if fire_scene:
		fire_particles = fire_scene.instantiate()
		camera.add_child(fire_particles)
		fire_particles.position = Vector3(0, -0.5, -1.0) # slightly below and in front of camera
		fire_particles.emitting = false

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
			
	var wants_to_fire = Input.is_action_pressed('dig')
	
	if wants_to_fire and current_fire_power > 0:
		if not is_firing:
			_start_firing()
			
		# Deplete Fire Power
		current_fire_power -= fire_depletion_rate * delta
		if current_fire_power <= 0:
			current_fire_power = 0
			_stop_firing()
	else:
		if is_firing:
			_stop_firing()
			
		# Regenerate if not firing (no cooldown block)
		if current_fire_power < max_fire_power:
			current_fire_power += fire_regen_rate * delta
			current_fire_power = min(current_fire_power, max_fire_power)

	if ui:
		ui.update_fire_power(current_fire_power, max_fire_power)

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
	
	_apply_fire_damage(delta)

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

func _start_firing() -> void:
	is_firing = true
	if fire_particles:
		fire_particles.emitting = true

func _stop_firing() -> void:
	is_firing = false
	if fire_particles:
		fire_particles.emitting = false

func _apply_fire_damage(delta: float) -> void:
	if not is_firing or not is_instance_valid(fire_area):
		return
		
	var overlapping_bodies = fire_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.has_method("take_damage"):
			# Apply damage over time
			body.take_damage(FIRE_DAMAGE * delta)

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
	current_fire_power = max_fire_power
	_stop_firing()
	
	if ui:
		ui.update_health(current_health, max_health)
		ui.update_fire_power(current_fire_power, max_fire_power)
