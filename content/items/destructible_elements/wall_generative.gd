extends Node3D

@export var wall_length: int = 40
@export var wall_height: int = 40
@export var brick_size: Vector3 = Vector3(0.25, 0.065, 0.12)
const brick_scene = preload("uid://cv5yvklfp6ae6")

func _ready():
	build_wall()

func build_wall():
	for y in range(wall_height):
		for x in range(wall_length):
			var brick = brick_scene.instantiate()
			add_child(brick)

			# Optional offset for staggered bricks
			var offset_x = 0.0
			if y % 2 == 1:
				offset_x = brick_size.x * 0.5

			brick.global_position = global_position + Vector3(
				x * brick_size.x + offset_x,
				y * brick_size.y,
				0
			)
