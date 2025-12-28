extends Node3D


@export var cube_scene: PackedScene
@export var layers: int = 10
@export var cube_size: float = 1.0

func _ready():
	generate_pyramid()

func generate_pyramid():
	if cube_scene == null:
		push_error("Cube scene not assigned!")
		return

	for y in range(layers):
		var cubes_per_side = layers - y
		var offset = (cubes_per_side - 1) * cube_size * 0.5

		for x in range(cubes_per_side):
			for z in range(cubes_per_side):
				var cube := cube_scene.instantiate()
				
				cube.position = Vector3(
					x * cube_size - offset,
					y * cube_size,
					z * cube_size - offset
				)

				add_child(cube)
