extends Node3D
class_name Weapon

@export var weapon_name: String = "Weapon"
@export var max_power: float = 100.0
@export var power_depletion_rate: float = 25.0
@export var power_regen_rate: float = 10.0

var current_power: float

func _ready() -> void:
    current_power = max_power

# Expected to be overridden
func fire(_delta: float) -> void:
    pass

# Expected to be overridden
func stop_fire() -> void:
    pass

func regenerate_power(delta: float) -> void:
    if current_power < max_power:
        current_power += power_regen_rate * delta
        current_power = min(current_power, max_power)
