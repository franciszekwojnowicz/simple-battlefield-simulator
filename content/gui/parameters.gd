extends Control

@onready var temperature_inside: Label = $TemperatureInside
@onready var temperature_outside: Label = $TemperatureOutside



var baloon: Baloon
var update_parameters: float = 0

func _ready() -> void:
	baloon = get_tree().get_first_node_in_group("baloon")

func _physics_process(delta: float) -> void:
	if update_parameters >= 1:
		temperature_inside.text =  "Temp inside: " + str((round(baloon.t_inside_baloon*100)/100)-273.15) + "°C"
		temperature_outside.text =  "Temp outside: " + str((round(baloon.t_outside_baloon*100)/100)-273.15) + "°C"
		
		update_parameters = 0
	update_parameters += delta
