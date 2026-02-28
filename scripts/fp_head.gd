extends Node3D

var sensitivity = 0.2

# This captures the mouse in the game so it can't leave the winodw.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		
		# This ensures that the player doesnt look past 90 degrees above and below.
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
