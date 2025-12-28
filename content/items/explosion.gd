extends Node3D

@onready var debris: GPUParticles3D = $Debris
@onready var smoke: GPUParticles3D = $Smoke
@onready var fire: GPUParticles3D = $Fire
@onready var explosion_sound: AudioStreamPlayer3D = $ExplosionSound

@export var root_child : bool = true
@export var explosion_scale : Vector3 = Vector3(1.0,1.0,1.0)
@export var smoke_amount : int = 16
@export var debris_amount : int = 24
@export var fire_amount : int = 12


func _ready() -> void:
	smoke.amount = smoke_amount
	debris.amount = debris_amount
	fire.amount = fire_amount
	scale = explosion_scale


func explosion() -> void:
	debris.emitting = true
	fire.emitting = true
	smoke.emitting = true
	explosion_sound.play()


var counter : float = 0.0
func _physics_process(delta: float) -> void:
	if root_child:
		if counter > 4.0:
			queue_free()
		counter += delta
