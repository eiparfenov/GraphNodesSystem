extends Control
class_name GraphNode3dUi

var connector_scene = preload("res://graph_nodes/connector.tscn")
@onready var input = $MarginContainer/HBoxContainer/Input
@onready var output = $MarginContainer/HBoxContainer/Output


signal pointer_entered(connector_idx, connector_type)
signal pointer_exited(connector_idx, connector_type)
signal pointer_down(connector_idx, connector_type)
signal pointer_up(connector_idx, connector_type)


func fill_node(input_contract, output_contract):
	for idx in input_contract.size():
		var input_contract_variant = input_contract[idx]
		var connector = connector_scene.instantiate()
		connector.idx = idx
		connector.connector_type = Connector.ConnectorType.InputConnector
		_connect_to_connectors_signals(connector)
		connector.get_node("Label").text = input_contract_variant
		input.add_child(connector)
	
	for idx in output_contract.size():
		var output_contract_variant = output_contract[idx]
		var connector = connector_scene.instantiate()
		connector.idx = idx
		connector.connector_type = Connector.ConnectorType.OutputConnector
		_connect_to_connectors_signals(connector)
		connector.get_node("Label").text = output_contract_variant
		output.add_child(connector)


func _connect_to_connectors_signals(connector: Connector):
	connector.pointer_entered.connect(func(connector_idx, connector_type): pointer_entered.emit(connector_idx, connector_type))
	connector.pointer_exited.connect(func(connector_idx, connector_type): pointer_exited.emit(connector_idx, connector_type))
	connector.pointer_down.connect(func(connector_idx, connector_type): pointer_down.emit(connector_idx, connector_type))
	connector.pointer_up.connect(func(connector_idx, connector_type): pointer_up.emit(connector_idx, connector_type))
	
	
