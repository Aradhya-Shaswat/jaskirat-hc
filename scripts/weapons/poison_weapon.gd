extends Weapon
class_name PoisonWeapon

const POISON_DPS := 10.0
const POISON_DURATION := 3.0
const POISON_RANGE := 15.0

var poison_area: Area3D
var poison_particles: GPUParticles3D
var is_firing := false

func _ready() -> void:
    weapon_name = "Poison"
    max_power = 100.0
    # 100 power / 15 seconds to drain = ~6.6 power/sec drain?
    # Actually, the requirement says "Refills gradually to full in 15 seconds"
    # So power_regen_rate = 100.0 / 15.0
    power_regen_rate = 100.0 / 15.0
    
    # Drain while holding - let's say it drains over 5 seconds of continuous fire
    power_depletion_rate = 20.0 
    current_power = max_power
    
    # 1. Setup Area3D for collision detection
    poison_area = Area3D.new()
    poison_area.collision_layer = 0
    poison_area.collision_mask = 2 # Assuming enemies are on layer 2
    add_child(poison_area)
    
    var poison_collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(2.0, 2.0, POISON_RANGE)
    poison_collision.shape = shape
    poison_collision.position = Vector3(0, 0, -POISON_RANGE / 2.0)
    poison_area.add_child(poison_collision)
    
    # 2. Setup Particles
    var poison_scene = load("res://scenes/particles/poison.tscn")
    if poison_scene:
        poison_particles = poison_scene.instantiate()
        add_child(poison_particles)
        poison_particles.position = Vector3(0, -0.2, -1.0)
        poison_particles.emitting = false

func fire(delta: float) -> void:
    is_firing = true
    if poison_particles:
        poison_particles.emitting = true
        
    current_power -= power_depletion_rate * delta
    if current_power <= 0:
        current_power = 0
        stop_fire()
        return
        
    var overlapping_bodies = poison_area.get_overlapping_bodies()
    for body in overlapping_bodies:
        # Check if the enemy has a method to take DoT
        if body.has_method("apply_poison"):
            body.apply_poison(POISON_DPS, POISON_DURATION)

func stop_fire() -> void:
    is_firing = false
    if poison_particles:
        poison_particles.emitting = false
