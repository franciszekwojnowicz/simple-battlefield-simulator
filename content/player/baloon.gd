extends CharacterBody3D

# Movement speed in meters per second
var speed: float = 10.0
# Jump impulse strength
var jump_velocity: float = 4.5
# Gravity (default to project setting)
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var cam : Camera3D
var is_moving = false

var BULLET = preload("uid://cimw3lovbsfxb")
var shoot_dir : Vector3

@onready var cannon: Node3D = $Cannon
@onready var point: Node3D = $Cannon/Point

# force net variables
var force_net : float = 0.0 #N
@export var t_inside_baloon : float = 290.0 #K  #350
@export var t_outside_baloon : float = 290.0 #K
@export var baloon_mass : float = 500.0 #kg
@export var baloon_volume : float = 5000.0 #m3
@export var preassure : float = 101325 #Pa
@export var gas_constant : float = 287.0 #J/(kg*K)

@onready var temperature_loss_timer: Timer = $TemperatureLossTimer
var timer_on = false

func _ready():
	cam = get_node("CameraPivot/CameraIsometric")  # adjust path if needed


func _physics_process(delta: float) -> void:
	if not cam:
		return
	moving(delta)
	cannon.global_rotation.x = - cam.global_rotation.x - deg_to_rad(40)
	cannon.global_rotation.y =   cam.global_rotation.y + deg_to_rad(180)
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	
func moving(delta) -> void:

	# Get input direction 
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Get Camera direction
	var cam_axis = cam.global_transform.basis.z.normalized()
	var direction = cam_axis.normalized()
	shoot_dir = -direction
	direction.y = 0
	direction = direction.normalized()
	
	var temp_direction = [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
	
	if Input.is_action_pressed("move_back"):
		temp_direction[0] = direction
	if Input.is_action_pressed("move_forward"):
		temp_direction[1] = -direction
	if Input.is_action_pressed("move_left"):
		temp_direction[2] = direction.cross(Vector3.UP)
	if Input.is_action_pressed("move_right"):
		temp_direction[3] = -direction.cross(Vector3.UP)
	
	direction = temp_direction[0] + temp_direction[1] + temp_direction[2] + temp_direction[3]
	
	if input_vector:
		is_moving = true
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		is_moving = false
	
	# brake when there is no key pressed
	if not is_moving and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	
	force_net = (gravity * baloon_volume * (preassure/gas_constant) * (1/t_outside_baloon - 1/t_inside_baloon) - baloon_mass * gravity) 
	velocity.y = force_net / (baloon_mass + baloon_volume*(preassure/(gas_constant*t_inside_baloon)))
	
	if Input.is_action_pressed("burn"):
		t_inside_baloon += 1 * delta  * 5

	
	if not timer_on:
		temperature_loss_timer.start(4)
		timer_on = true

	print(t_inside_baloon)
	# Apply movement
	move_and_slide()




func shoot():
	var bullet = BULLET.instantiate()
	# Assign your direction
	shoot_dir = - cannon.global_position + point.global_position
	bullet.direction = shoot_dir.normalized()
	get_tree().root.add_child(bullet)
	bullet.global_position=point.global_position


func _on_temperature_loss_timer_timeout() -> void:
	t_inside_baloon -= 1
	t_inside_baloon = max (t_outside_baloon, t_inside_baloon)
	timer_on = false
