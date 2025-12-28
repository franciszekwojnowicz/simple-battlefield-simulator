extends CharacterBody3D
class_name Baloon

## Movement speed in meters per second
var speed: float = 30.0
## Jump impulse strength
var jump_velocity: float = 4.5
## Gravity (default to project setting)
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Cameras
## Isometric baloon camera
@onready var camera_isometric: Camera3D = $CameraPivot/CameraIsometric

var camera_mode_bullet = false

# bullet and its direction
var BULLET = preload("uid://cimw3lovbsfxb")
var shoot_dir : Vector3

@onready var cannon: Node3D = $Cannon
@onready var point: Node3D = $Cannon/Point
@onready var cannon_sound: AudioStreamPlayer3D = $CannonSound

@onready var turret: MeshInstance3D = $baloon_parts/Turret


@onready var heater: GPUParticles3D = $baloon_parts/Sphere/Heater
@onready var gas_burn: AudioStreamPlayer3D = $GasBurn
@onready var engine: MeshInstance3D = $baloon_parts/Engine

@onready var engine_north: GPUParticles3D = $baloon_parts/Engine/EngineNorth
@onready var engine_south: GPUParticles3D = $baloon_parts/Engine/EngineSouth
@onready var engine_east: GPUParticles3D = $baloon_parts/Engine/EngineEast
@onready var engine_west: GPUParticles3D = $baloon_parts/Engine/EngineWest



# Baloon phisic variables #########################################################
## Describe the temperature inside the baloon
@export var t_inside_baloon : float = 290.0 #K  #350
## Describe the temperature outside the baloon
@export var t_outside_baloon : float = 290.0 #K
## Describe baloon mass without the air inside
@export var baloon_mass : float = 800.0 #kg
## Describe baloon evelope radius
@export var evelope_radius : float = 11 #m
## Describe baloon surface from above, for air resistance
var surface_from_above: float = PI * evelope_radius * evelope_radius #m2
## Describe baloon inside volume in m3
var baloon_volume : float = 4.0/3.0 * PI * evelope_radius * evelope_radius * evelope_radius #m3
## Describe atmospheric pressure
@export var preassure : float = 101325 #Pa
## Desribe air resistance value for specific shape
@export var drag_coefficient = 0.7
## Describe gas constant for air
var gas_constant : float = 287.0 #J/(kg*K)

# timer variables
@onready var temperature_loss_timer: Timer = $TemperatureLossTimer
var timer_on = false

## Describe differnce between forces which afect the baloon in up/down direction
var force_net : float = 0.0 #N
## Describe air redsistance force dependent on current velocity
var air_resistance_force : float
## Describe net force including air resistance
var final_force_net : float

# Wind components
var wind_strength : int = 0
var wind_force : Vector3 = Vector3.ZERO
@onready var wind_change_timer: Timer = $WindChangeTimer
var wind_change_is_comming : bool = true
var wind_change_period : float = 10.0



func _ready() -> void:
	add_to_group("baloon")


func _physics_process(delta: float) -> void:
	moving(delta)
	cannon_mechanics()
	temperature_mechanics(delta)


## Takes intput from keybord and transform it into baloon movement
func moving(delta) -> void:
	# Get Camera direction
	var direction = camera_isometric.global_transform.basis.z.normalized()
	shoot_dir = -direction
	direction.y = 0
	direction = direction.normalized()
	
	# calculate direction based on input keys
	var temp_direction = [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
	if Input.is_action_pressed("move_back"):
		temp_direction[0] = direction
		engine_south.emitting = true
	else:
		engine_south.emitting = false
	if Input.is_action_pressed("move_forward"):
		temp_direction[1] = -direction
		engine_north.emitting = true
	else:
		engine_north.emitting = false
	if Input.is_action_pressed("move_left"):
		temp_direction[2] = direction.cross(Vector3.UP)
		engine_west.emitting = true
	else:
		engine_west.emitting = false
	if Input.is_action_pressed("move_right"):
		temp_direction[3] = -direction.cross(Vector3.UP)
		engine_east.emitting = true
	else:
		engine_east.emitting = false
	direction = temp_direction[0] + temp_direction[1] + temp_direction[2] + temp_direction[3]
	

		
	var air_resistanse_x = (((surface_from_above) * 1.1 *velocity.x*velocity.x*(preassure/(gas_constant*t_outside_baloon)))/2) / (baloon_mass + baloon_volume*(preassure/(gas_constant*t_inside_baloon))) * delta 
	if velocity.x > 3 or velocity.x < -3:
		velocity.x = move_toward(velocity.x,0,air_resistanse_x)
	else:
		velocity.x = move_toward(velocity.x, 0, delta)
	
	var air_resistanse_z = (((surface_from_above) * 1.1 *velocity.z*velocity.z*(preassure/(gas_constant*t_outside_baloon)))/2) / (baloon_mass + baloon_volume*(preassure/(gas_constant*t_inside_baloon))) * delta
	if velocity.z > 3 or velocity.z < -3:
		velocity.z = move_toward(velocity.z,0,air_resistanse_z)
	else:
		velocity.z = move_toward(velocity.z, 0, delta)
		
	if is_on_floor():
		velocity.z = move_toward(velocity.z, 0, speed * delta * 0.5)
		velocity.x = move_toward(velocity.x, 0, speed * delta * 0.5)
	
	var wind_change = wind_mechanics() 
	if not is_on_floor():
		velocity += wind_change * delta
		
	# Apply velocity
	if Input.get_vector("move_left", "move_right", "move_forward", "move_back"):
		velocity.x += direction.x * speed * delta
		velocity.z += direction.z * speed  * delta
	
	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity * 5
	
	# calculate baloon net velocity up/down and apply movement
	velocity.y += calculate_acceleration_y() * delta
	move_and_slide()


## Calculate current acceleration including gravity, buoyancy and air resistance
func calculate_acceleration_y() -> float:
	force_net = (gravity * baloon_volume * (preassure/gas_constant) * (1/t_outside_baloon - 1/t_inside_baloon) - baloon_mass * gravity)
	air_resistance_force = (surface_from_above*0.8*velocity.y*velocity.y*(preassure/(gas_constant*t_outside_baloon)))/2
	final_force_net = force_net
	# apply air resistance agains current movement direction
	if velocity.y >= 0.1:
		final_force_net = force_net - air_resistance_force
	elif velocity.y <= -0.1:
		final_force_net = force_net + air_resistance_force
	return (final_force_net / (baloon_mass + baloon_volume*(preassure/(gas_constant*t_inside_baloon))))


## Manage cannon rotation mased on mose/camera movement and apply shooting
func cannon_mechanics() -> void:
	# apply cannon rotation towards the current camera view
	cannon.global_rotation.x = - camera_isometric.global_rotation.x - deg_to_rad(20)
	
	cannon.global_rotation.y = camera_isometric.global_rotation.y + deg_to_rad(180)
	turret.global_rotation.y = camera_isometric.global_rotation.y + deg_to_rad(180)
	engine.global_rotation.y = camera_isometric.global_rotation.y - deg_to_rad(90)
	if Input.is_action_just_pressed("shoot"):
		shoot()


func wind_mechanics() -> Vector3:
	if wind_change_is_comming:
		wind_change_is_comming = false
		wind_strength = randi() % 10
		wind_force = Vector3(randf_range(-1,1),0,randf_range(-1,1)) * wind_strength
		wind_change_timer.start(wind_change_period)
	return wind_force



## Create new instance of bullet scene and add a cannon's direction to the bullet velocity
func shoot() -> void:
	cannon_sound.play()
	var bullet : Bullet = BULLET.instantiate()
	# Assign your direction
	shoot_dir = - cannon.global_position + point.global_position
	bullet.direction = shoot_dir.normalized()
	get_tree().root.add_child(bullet)
	bullet.global_position=point.global_position
	# rotate bullet what is necessary for camera
	bullet.global_rotation.x = - camera_isometric.global_rotation.x - deg_to_rad(40)
	bullet.global_rotation.y =   camera_isometric.global_rotation.y + deg_to_rad(180)
	if camera_mode_bullet:
		bullet.camera_bullet.current = true


## Manage temperature rise and loss, when key pressed heat the air, temperature decreasses over time
func temperature_mechanics(delta):
	if Input.is_action_pressed("burn"):
		t_inside_baloon += 1 * delta  * 5
		heater.emitting = true
		if not gas_burn.playing:
			gas_burn.play()
	else:
		heater.emitting = false
		gas_burn.stop()
	if not timer_on:
		temperature_loss_timer.start(4)
		timer_on = true


## Decrease temperature inside baloon's envelope over time
func _on_temperature_loss_timer_timeout() -> void:
	t_inside_baloon -= 1
	t_inside_baloon = max (t_outside_baloon, t_inside_baloon)
	timer_on = false
	#print("air resistance: " + str(air_resistance_force))
	#print("net force: " + str(force_net))
	#print("velocity: " + str((round(velocity.y*100)/100)))


func _on_wind_change_timer_timeout() -> void:
	wind_change_is_comming = true
