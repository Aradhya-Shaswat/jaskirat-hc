extends CanvasLayer

func _ready() -> void:
	visible = false
	
	if not InputMap.has_action("ui_cancel"):
		InputMap.add_action("ui_cancel")
		var escape_key = InputEventKey.new()
		escape_key.keycode = KEY_ESCAPE
		InputMap.action_add_event("ui_cancel", escape_key)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			_resume()
		else:
			_pause()

func _pause() -> void:
	get_tree().paused = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _resume() -> void:
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed() -> void:
	_resume()

func _on_quit_pressed() -> void:
	get_tree().quit()
