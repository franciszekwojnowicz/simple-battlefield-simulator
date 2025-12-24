@tool
extends MultiMeshInstance3D

@export var terrain_chunk: MeshInstance3D
@export var tree_mesh: Mesh
@export var trees_per_chunk := 1000

func _ready():


	if !multimesh:
		var mm := MultiMesh.new()
		mm.mesh = tree_mesh
		mm.transform_format = MultiMesh.TRANSFORM_3D
		multimesh = mm

	multimesh.instance_count = trees_per_chunk
