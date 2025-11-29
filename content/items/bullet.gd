extends RigidBody3D

@export var speed := 40.0
var direction := Vector3.ZERO

func _ready():
	linear_velocity = direction * speed
	await get_tree().create_timer(15).timeout
	continuous_cd = true
	queue_free()

func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0:
		look_at(global_transform.origin + linear_velocity, Vector3.UP)
