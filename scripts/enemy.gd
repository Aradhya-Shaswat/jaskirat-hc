extends CharacterBody3D

const SPEED = 4.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var max_health: float = 50.0
var current_health: float

@export var attack_damage: float = 15.0 # Damage per hit
@export var attack_range: float = 1.5
@export var attack_cooldown: float = 1.0
var current_attack_cooldown: float = 0.0

var player: Node3D

func _ready() -> void:
    current_health = max_health
    # Find the player in the scene
    player = get_tree().get_first_node_in_group("player")
    if not player:
        # Fallback if group is not set up
        player = get_node_or_null("../player")

func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    if player:
        # Chase the player
        var direction = global_position.direction_to(player.global_position)
        # Keep it on the ground
        direction.y = 0
        direction = direction.normalized()
        
        
        if velocity.length() < SPEED:
            velocity.x = direction.x * SPEED
            velocity.z = direction.z * SPEED
            
        # Handle attack cooldown
        if current_attack_cooldown > 0:
            current_attack_cooldown -= delta
            
        # Check distance and attack
        var distance_to_player = global_position.distance_to(player.global_position)
        if distance_to_player <= attack_range and current_attack_cooldown <= 0:
            if player.has_method("take_damage"):
                player.take_damage(attack_damage)
                current_attack_cooldown = attack_cooldown
    
    move_and_slide()

func take_damage(amount: float) -> void:
    current_health -= amount
    
    # Optional visual feedback here
    
    if current_health <= 0:
        die()

func die() -> void:
    queue_free()
