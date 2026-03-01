extends CanvasLayer
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var weapon_power_bar: ProgressBar = $MarginContainer/VBoxContainer/WeaponPowerBar
@onready var weapon_label: Label = $MarginContainer/VBoxContainer/WeaponLabel
@onready var stage_label: Label = $MarginContainer/TopCenterContainer/StageLabel

@export var health_style: StyleBoxFlat
@export var fire_style: StyleBoxFlat
@export var poison_style: StyleBoxFlat

@onready var pyramid_indicator: Control = $MarginContainer/BottomRightContainer/PyramidIndicator

func _ready() -> void:
	if health_style:
		health_bar.add_theme_stylebox_override("fill", health_style)
	if fire_style == null:
		fire_style = StyleBoxFlat.new()
		fire_style.bg_color = Color(0.9, 0.5, 0.1)
	if poison_style == null:
		poison_style = StyleBoxFlat.new()
		poison_style.bg_color = Color(0.6, 0.1, 0.9)

func _process(_delta: float) -> void:
	if pyramid_indicator:
		# Hide if paused
		pyramid_indicator.visible = not get_tree().paused

func update_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

func update_stage(current_stage: int) -> void:
	if stage_label:
		stage_label.text = "Stage %d / 5" % current_stage

func update_active_weapon(weapon: Weapon) -> void:
	if not weapon:
		return
	weapon_power_bar.max_value = weapon.max_power
	weapon_power_bar.value = weapon.current_power
	weapon_label.text = "Weapon: " + weapon.weapon_name + " [1/2 to switch]"

	if weapon.weapon_name == "Fire":
		weapon_power_bar.add_theme_stylebox_override("fill", fire_style)
	else:
		weapon_power_bar.add_theme_stylebox_override("fill", poison_style)

func update_stage_progress(stage: int, progress: float) -> void:
	if pyramid_indicator:
		pyramid_indicator.current_stage = stage
		pyramid_indicator.stage_progress = progress
