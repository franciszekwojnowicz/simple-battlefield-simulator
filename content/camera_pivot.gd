extends Node3D

@export var sensitivity := 0.15
@export var distance := 6.0
@export var height := 3.0
@export var smoothing := 8.0

var yaw := 0.0
var pitch := -20.0   # slight downward tilt

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, -60, 10)  # limit up/down
		rotation_degrees = Vector3(pitch, yaw, 0)

func _process(delta):
	# Smooth follow
	var player = get_parent()
	if player:
		var target_position = player.global_transform.origin

		# Camera position offset above & behind
		var cam_offset = Vector3(0, height, distance)
		cam_offset = global_transform.basis * cam_offset

		var camera = $Camera3D
		var desired_cam_pos = target_position + cam_offset

		camera.global_transform.origin = camera.global_transform.origin.lerp(desired_cam_pos, delta * smoothing)
