extends RigidBody3D

@export var speed := 200.0
var direction := Vector3.ZERO

func _ready():
	linear_velocity = direction * speed
	continuous_cd = true
	await get_tree().create_timer(15).timeout
	queue_free()

#func _physics_process(_delta: float) -> void:
	#if linear_velocity.length() > 0:
		#look_at(global_transform.origin + linear_velocity, Vector3.UP)
