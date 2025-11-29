extends CharacterBody3D

# Movement speed in meters per second
@export var speed: float = 10.0
# Jump impulse strength
@export var jump_velocity: float = 4.5
# Gravity (default to project setting)
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var cam : Camera3D

var moving = false

func _ready():
	cam = get_node("CameraPivot/Camera3D")  # adjust path if needed

func _physics_process(delta: float) -> void:
	if not cam:
		return
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get input direction (normalized)
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	
	var cam_basis = cam.global_transform.basis.z.normalized()
	var cam_axis = cam_basis
	
	#var direction = (relative_camera_position * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	var direction = cam_axis.normalized()
	direction.y = 0
	direction = direction.normalized()
	print(direction)
	if input_vector:
		moving = true
	else:
		moving = false
	
	if Input.is_action_just_pressed("move_back"):
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	if Input.is_action_pressed("move_forward"):
		velocity.x = -direction.x * speed
		velocity.z = -direction.z * speed
	if Input.is_action_pressed("move_left"):
		velocity.x = direction.cross(Vector3.UP).x * speed
		velocity.z = direction.cross(Vector3.UP).z * speed
	if Input.is_action_pressed("move_right"):
		velocity.x = -direction.cross(Vector3.UP).x * speed
		velocity.z = -direction.cross(Vector3.UP).z * speed
	
	if not moving:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	# Apply movement
	move_and_slide()
	
	# Jumping
	if Input.is_action_just_pressed("ui_text_backspace") and is_on_floor():
		velocity.y = jump_velocity
