extends Node3D

@export var sensitivity := 0.15
@export var distance := 6.0
@export var min_distance := 2.0
@export var max_distance := 12.0
@export var height := 3.0
@export var smoothing := 8.0

var yaw := 0.0
var pitch := -20.0   # slight downward tilt

var baloon : Baloon


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, -50, 30)  # limit up/down
		rotation_degrees = Vector3(pitch, yaw, 0)
	
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP and event.pressed:
			distance -= 0.5  # zoom in
			height -= 0.5
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			distance += 0.5  # zoom out
			height += 0.5
		#distance = clamp(distance, min_distance, max_distance)
	
	if event.is_action_pressed("switch_camera"):
		baloon.camera_mode_bullet = !baloon.camera_mode_bullet

func _process(delta):
	# Smooth follow
	baloon = get_parent()
	if baloon:
		var target_position = baloon.global_transform.origin

		# Camera position offset above & behind
		var cam_offset = Vector3(0, height, distance)
		cam_offset = global_transform.basis * cam_offset

		var camera = $CameraIsometric
		var desired_cam_pos = target_position + cam_offset

		camera.global_transform.origin = camera.global_transform.origin.lerp(desired_cam_pos, delta * smoothing)
