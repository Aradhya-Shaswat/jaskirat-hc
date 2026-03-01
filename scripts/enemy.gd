extends CharacterBody3D

const SPEED = 4.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var max_health: float = 30.0
var current_health: float

@export var attack_damage: float = 15.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

var poison_dps: float = 0.0
var poison_timer: float = 0.0

@onready var health_bar: ProgressBar = $HealthBarViewport/ProgressBar
var player: Node3D

var hit_audio: AudioStreamPlayer3D

func _ready() -> void:
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = max_health

	hit_audio = AudioStreamPlayer3D.new()
	hit_audio.stream = load("res://sounds/Free Sounds Pack/Hit Generic 2-1.wav")
	add_child(hit_audio)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if poison_timer > 0:
		poison_timer -= delta
		take_damage(poison_dps * delta)
		if health_bar:
			health_bar.value = current_health
		if poison_timer <= 0:
			poison_dps = 0.0

	if player:
		var flat_pos = Vector2(global_position.x, global_position.z)
		var flat_target = Vector2(player.global_position.x, player.global_position.z)
		var distance_to_player = flat_pos.distance_to(flat_target)

		attack_timer -= delta

		if distance_to_player > attack_range:

			var direction = global_position.direction_to(player.global_position)
			direction.y = 0
			direction = direction.normalized()

			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:

			velocity.x = 0
			velocity.z = 0

			if attack_timer <= 0 and player.has_method("take_damage"):
				player.take_damage(attack_damage)
				attack_timer = attack_cooldown

		if flat_pos.distance_to(flat_target) > 0.1:
			var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(look_target, Vector3.UP)

	move_and_slide()

func take_damage(amount: float) -> void:
	current_health -= amount
	if health_bar:
		health_bar.value = current_health
	
	# if hit_audio:
	# 	hit_audio.play()

	if current_health <= 0:
		queue_free()

func apply_poison(dps: float, duration: float) -> void:
	poison_timer = duration
	if dps > poison_dps:
		poison_dps = dps
