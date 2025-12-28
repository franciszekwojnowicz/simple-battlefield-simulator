extends MeshInstance3D

@onready var engine_north: GPUParticles3D = $EngineNorth
@onready var engine_south: GPUParticles3D = $EngineSouth
@onready var engine_east: GPUParticles3D = $EngineEast
@onready var engine_west: GPUParticles3D = $EngineWest



func _physics_process(_delta: float) -> void:
	engine_west.process_material.gravity = engine_west.global_transform.basis.inverse() * (engine_west.global_position - global_position)
	engine_south.process_material.gravity = engine_south.global_transform.basis.inverse() * (engine_south.global_position - global_position)
	engine_north.process_material.gravity = engine_north.global_transform.basis.inverse() * (engine_north.global_position - global_position)
	engine_east.process_material.gravity = engine_east.global_transform.basis.inverse() * (engine_east.global_position - global_position)
