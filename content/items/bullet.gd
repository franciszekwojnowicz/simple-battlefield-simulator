extends RigidBody3D

@export var speed := 200.0
var direction := Vector3.ZERO

@onready var area_3d: Area3D = $Area3D


func _ready():
	linear_velocity = direction * speed
	continuous_cd = true
	add_to_group("bullet")
	await get_tree().create_timer(15).timeout
	queue_free()

#func _physics_process(_delta: float) -> void:
	#if linear_velocity.length() > 0:
		#look_at(global_transform.origin + linear_velocity, Vector3.UP)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("brick"):
		body.freeze= false
		#var force = linear_velocity.length() * 0.2
		#body.apply_impulse(Vector3.ZERO,linear_velocity.normalized() * force)
