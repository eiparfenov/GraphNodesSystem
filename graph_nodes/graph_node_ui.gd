extends Control
class_name GraphNode3dUi

var connector_scene = preload("res://graph_nodes/connector.tscn")
@onready var input = $MarginContainer/HBoxContainer/Input
@onready var output = $MarginContainer/HBoxContainer/Output



func fill_node(input_contract, output_contract):
	for input_contract_variant in input_contract:
		var connector = connector_scene.instantiate()
		connector.get_node("Label").text = input_contract_variant
		input.add_child(connector)
	
	for output_contract_variant in output_contract:
		var connector = connector_scene.instantiate()
		connector.get_node("Label").text = output_contract_variant
		output.add_child(connector)
