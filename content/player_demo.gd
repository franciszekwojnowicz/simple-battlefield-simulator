extends CharacterBody3D

# Movement speed in meters per second
@export var speed: float = 6.0
# Jump impulse strength
@export var jump_velocity: float = 4.5
# Gravity (default to project setting)
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get input direction (normalized)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Move in direction
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Jumping
	if Input.is_action_just_pressed("ui_text_backspace") and is_on_floor():
		velocity.y = jump_velocity

	# Apply movement
	move_and_slide()
