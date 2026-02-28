extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var fire_power_bar: ProgressBar = $MarginContainer/VBoxContainer/FirePowerBar

func _ready() -> void:
    # Set custom styles if needed, or rely on Godot defaults
    var health_style = StyleBoxFlat.new()
    health_style.bg_color = Color(0.8, 0.1, 0.1)
    health_bar.add_theme_stylebox_override("fill", health_style)
    
    var fire_style = StyleBoxFlat.new()
    fire_style.bg_color = Color(0.9, 0.5, 0.1)
    fire_power_bar.add_theme_stylebox_override("fill", fire_style)

func update_health(current: float, maximum: float) -> void:
    health_bar.max_value = maximum
    health_bar.value = current

func update_fire_power(current: float, maximum: float) -> void:
    fire_power_bar.max_value = maximum
    fire_power_bar.value = current
