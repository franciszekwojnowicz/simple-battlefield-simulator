extends ColorRect


var baloon: Baloon
var update_parameters: float = 0
@onready var compass_face: TextureRect = $CompassFace


@onready var wind_tip: ColorRect = $WindTip

var current_direction : Vector3 = Vector3.ZERO
@onready var wind_strength: Label = $WindStrength


func _ready() -> void:
	baloon = get_tree().get_first_node_in_group("baloon")
	
func _physics_process(delta: float) -> void:
	current_direction = baloon.shoot_dir
	current_direction.y = 0
	if current_direction.z > 0:
		compass_face.rotation = - Vector3(1,0,0).angle_to(current_direction) 
	else:
		compass_face.rotation = Vector3(1,0,0).angle_to(current_direction) 
	
	
	if baloon.wind_force.z > 0:
		wind_tip.rotation =   Vector3(1,0,0).angle_to(baloon.wind_force)  
	else:
		wind_tip.rotation =  - Vector3(1,0,0).angle_to(baloon.wind_force) 

	
	if update_parameters >= 0.5:
		wind_strength.text = "Wind strength: " + str((round(baloon.wind_force.length()*100)/100))
		update_parameters = 0
	update_parameters += delta
		
	
