extends RigidBody3D
class_name Bullet

@export var speed := 200.0
var direction := Vector3.ZERO

@onready var area_3d: Area3D = $Area3D
@onready var particle_trails: GPUParticles3D = $ParticleTrails

@onready var camera_bullet: Camera3D = $CameraBullet


func _ready():
	linear_velocity = direction * speed
	continuous_cd = true
	add_to_group("bullet")
	await get_tree().create_timer(15).timeout
	queue_free()

#func _physics_process(_delta: float) -> void:
	#if linear_velocity.length() > 0:
		#look_at(global_transform.origin + linear_velocity, Vector3.UP)




func _physics_process(_delta: float) -> void:
	# Somehow it works
	camera_bullet.global_position = global_position - linear_velocity.normalized()
	camera_bullet.look_at(global_position + linear_velocity.normalized(), Vector3.UP)
	#camera_bullet.global_rotation = global_rotation
	camera_bullet.global_rotation.y = global_rotation.y + deg_to_rad(180)
	#camera_bullet.global_rotation.z = linear_velocity.z
	#camera_bullet.global_rotation.x = linear_velocity.x
	
	if linear_velocity.length() < 100:
		particle_trails.emitting = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("brick"):
		body.freeze= false
		#var force = linear_velocity.length() * 0.2
		#body.apply_impulse(Vector3.ZERO,linear_velocity.normalized() * force)
	await get_tree().create_timer(0.1).timeout
	camera_bullet.current = false
