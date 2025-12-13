extends Control

@onready var temperature_inside: Label = $TemperatureInside
@onready var temperature_outside: Label = $TemperatureOutside
@onready var height_above_the_ground: Label = $HeightAboveTheGround
@onready var velocity_up_down: Label = $VelocityUpDown



var baloon: Baloon
var update_parameters: float = 0

func _ready() -> void:
	baloon = get_tree().get_first_node_in_group("baloon")

func _physics_process(delta: float) -> void:
	if update_parameters >= 1:
		temperature_inside.text =  "Temp inside: " + str((round(baloon.t_inside_baloon*100)/100)-273.15) + "°C"
		temperature_outside.text =  "Temp outside: " + str((round(baloon.t_outside_baloon*100)/100)-273.15) + "°C"
		height_above_the_ground.text = "Height: " + str((round(baloon.global_position.y*100)/100)-1) + " m"
		velocity_up_down.text = "Velocity: " + str((round(baloon.velocity.y*100)/100)) + " m/s"
		update_parameters = 0
	update_parameters += delta
