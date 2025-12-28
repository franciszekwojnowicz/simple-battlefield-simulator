extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("brick")
	contact_monitor = true
	max_contacts_reported = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
