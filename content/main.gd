extends Node3D

var mouse_mode_captured = true

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	# release/unrelease mouse cursor
	if Input.is_action_just_pressed("mouse_mode_switch"):
		if mouse_mode_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_mode_captured = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_mode_captured = true
