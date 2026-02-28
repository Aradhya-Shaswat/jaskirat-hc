extends Weapon
class_name FireWeapon

const FIRE_DAMAGE := 20.0
const FIRE_RANGE := 10.0

var fire_area: Area3D
var fire_particles: GPUParticles3D
var is_firing := false

func _ready() -> void:
    weapon_name = "Fire"
    max_power = 100.0
    power_depletion_rate = 25.0
    power_regen_rate = 100.0 / 15.0
    current_power = max_power
    
    # 1. Setup Area3D for collision detection
    fire_area = Area3D.new()
    fire_area.collision_layer = 0
    fire_area.collision_mask = 2 # Assuming enemies are on layer 2
    add_child(fire_area)
    
    var fire_collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(1.5, 1.5, FIRE_RANGE)
    fire_collision.shape = shape
    fire_collision.position = Vector3(0, 0, -FIRE_RANGE / 2.0)
    fire_area.add_child(fire_collision)
    
    # 2. Setup Particles
    var fire_scene = load("res://scenes/particles/fire.tscn")
    if fire_scene:
        fire_particles = fire_scene.instantiate()
        add_child(fire_particles)
        fire_particles.position = Vector3(0, -0.5, -1.0)
        fire_particles.emitting = false

func fire(delta: float) -> void:
    is_firing = true
    if fire_particles:
        fire_particles.emitting = true
        
    current_power -= power_depletion_rate * delta
    if current_power <= 0:
        current_power = 0
        stop_fire()
        return
        
    var overlapping_bodies = fire_area.get_overlapping_bodies()
    for body in overlapping_bodies:
        if body.has_method("take_damage"):
            body.take_damage(FIRE_DAMAGE * delta)

func stop_fire() -> void:
    is_firing = false
    if fire_particles:
        fire_particles.emitting = false
