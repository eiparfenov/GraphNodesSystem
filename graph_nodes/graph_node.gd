extends GUI
class_name GraphNode3D

@export var input_contract: Array[String]
@export var output_contract: Array[String]
var scene_self: PackedScene


@onready var node_ui: GraphNode3dUi = $Viewport/NodeUi

var id: int

signal pointer_enter(graph_node: GraphNode3D, connector_idx: int, connector_type: Connector.ConnectorType)
signal pointer_exit(graph_node: GraphNode3D, connector_idx: int, connector_type: Connector.ConnectorType)
signal pointer_down(graph_node: GraphNode3D, connector_idx: int, connector_type: Connector.ConnectorType)
signal pointer_up(graph_node: GraphNode3D, connector_idx: int, connector_type: Connector.ConnectorType)
signal moved(graph_node: GraphNode3D)
signal destroy_requested(graph_node: GraphNode3D)


func _ready():
	node_ui.fill_node(input_contract, output_contract)
	viewport.size = Vector2(410, 10 + 50 * max(input_contract.size(), output_contract.size()))
	super()


func get_connector_position(connector_type: Connector.ConnectorType, connector_idx: int) -> Vector3:
	var pos = Vector3(viewport.size.x / ppu / 2, - 50 / ppu * (connector_idx-.5), 0)
	if connector_type == Connector.ConnectorType.InputConnector:
		pos.x = -pos.x
	return to_global(pos)


func _on_node_ui_pointer_down(connector_idx, connector_type):
	pointer_down.emit(self, connector_idx, connector_type)


func _on_node_ui_pointer_entered(connector_idx, connector_type):
	pointer_enter.emit(self, connector_idx, connector_type)


func _on_node_ui_pointer_exited(connector_idx, connector_type):
	pointer_exit.emit(self, connector_idx, connector_type)


func _on_node_ui_pointer_up(connector_idx, connector_type):
	pointer_up.emit(self, connector_idx, connector_type)


func notify_move():
	moved.emit(self)



