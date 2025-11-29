extends RigidBody3D

@export var speed := 40.0
var direction := Vector3.ZERO

func _ready():
	linear_velocity = direction * speed
