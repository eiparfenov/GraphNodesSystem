extends Node3D


@export var work_state: WorkState
@export_file("*.txt") var data_path


var line_scene = preload("res://graph_nodes/line.tscn")

var preview_start_connector
var preview_line: Line3D
var preview_output_node: GraphNode3D
var preview_input_node: GraphNode3D
var preview_input_connector_idx: int
var preview_output_connector_idx: int
var preview_stayed_in_start_connector: bool

var graph_nodes: Array[GraphNode3D] = []
var connections: Array[Connection] = []


var current_node: GraphNode3D
var current_connector_idx


var is_in_loading_phase: bool

func _ready():
	if work_state == WorkState.Editor:
		preview_line = line_scene.instantiate()
		preview_line.name = "PreviewLine"
		preview_line.visible = false
		add_child(preview_line)
		_load_data()
	else:
		pass




func _save_data():
	if is_in_loading_phase: return
	
	var data = {
		nodes=[],
		connections=[],
	}
	
	for graph_node in graph_nodes:
		print(graph_node.global_position)
		data["nodes"].append({
			id = graph_node.id,
			position = graph_node.global_position,
			rotation = graph_node.global_rotation,
			scene_path = graph_node.scene_self.resource_path,
		})
	
	for connection in connections:
		data["connections"].append({
			input_node_id = connection.input_node.id,
			output_node_id = connection.output_node.id,
			input_connector_idx = connection.input_connector_idx,
			output_connector_idx = connection.output_connector_idx,
		})
	var file = FileAccess.open(data_path, FileAccess.WRITE)
	file.store_string(var_to_str(data))


func _load_data():
	is_in_loading_phase = true
	
	var file = FileAccess.open(data_path, FileAccess.READ)
	var data = str_to_var(file.get_as_text())
	print(data)
	
	var loaded_nodes = {}
	for graph_node in data.nodes:
		var loaded_node = create_graph_node(load(graph_node.scene_path), graph_node.position, graph_node.rotation, graph_node.id)
		loaded_nodes[loaded_node.id] = loaded_node
	
	for connection in data.connections:
		_create_connection(
			loaded_nodes[connection.input_node_id],
			connection.input_connector_idx,
			connection.output_connector_idx,
			loaded_nodes[connection.output_node_id]
			)
	
	is_in_loading_phase = false

func create_graph_node(node_scene: PackedScene, position: Vector3, rotation: Vector3, id = null):
	var graph_node_3d: GraphNode3D = node_scene.instantiate()
	graph_node_3d.id = id if id != null else graph_nodes.reduce(func(a, b): return a if a > b.id else b.id, -1) + 1
	graph_node_3d.name = "GraphNode3D {%s}" % graph_node_3d.id
	graph_node_3d.scene_self = node_scene
	graph_nodes.append(graph_node_3d)
	
	graph_node_3d.pointer_up.connect(_on_graph_node_3d_pointer_up)
	graph_node_3d.pointer_down.connect(_on_graph_node_3d_pointer_down)
	graph_node_3d.pointer_enter.connect(_on_graph_node_3d_pointer_enter)
	graph_node_3d.pointer_exit.connect(_on_graph_node_3d_pointer_exit)
	graph_node_3d.moved.connect(_on_graph_node_3d_moved)
	add_child(graph_node_3d)
	
	graph_node_3d.global_position = position
	graph_node_3d.global_rotation = rotation
	_save_data()
	return graph_node_3d


func handle_button_up():
	if preview_input_node != null and preview_output_node != null:
		_create_connection(preview_input_node, preview_input_connector_idx, preview_output_connector_idx, preview_output_node)
		_save_data()
	
	preview_input_node = null
	preview_output_node = null
	preview_start_connector = null
	preview_line.visible = false
	

func _on_graph_node_3d_pointer_up(graph_node: GraphNode3D, connector_idx, connector_type):
	print("up", current_node.id, current_connector_idx)
	if preview_stayed_in_start_connector: # Remove connections
		var connections_to_remove: Array[Connection] = []
		if connector_type == Connector.ConnectorType.InputConnector:
			connections_to_remove = connections.filter(func(connection): return connection.input_node == current_node and connection.input_connector_idx == current_connector_idx)
		else:
			connections_to_remove = connections.filter(func(connection): return connection.output_node == current_node and connection.output_connector_idx == current_connector_idx)
		
		for connection_to_remove in connections_to_remove:
			connection_to_remove.destroy()
			connections.erase(connection_to_remove)
		
		_save_data()
	
		preview_input_node = null
		preview_output_node = null
		preview_start_connector = null
		preview_line.visible = false
	
	
func _on_graph_node_3d_pointer_down(graph_node: GraphNode3D, connector_idx, connector_type):
	print("down", current_node.id, current_connector_idx)
	preview_stayed_in_start_connector = true
	preview_start_connector = connector_type
	if connector_type == Connector.ConnectorType.InputConnector:
		preview_input_node = current_node
		preview_input_connector_idx = current_connector_idx
	else:
		preview_output_connector_idx = current_connector_idx
		preview_output_node = current_node
	
	
func _on_graph_node_3d_pointer_enter(graph_node: GraphNode3D, connector_idx, connector_type):
	print("enter", graph_node.id, connector_idx)
	
	current_node = graph_node
	current_connector_idx = connector_idx
	
	if preview_start_connector == null: return
	if preview_start_connector == connector_type: return
	
	if preview_start_connector == Connector.ConnectorType.InputConnector:
		preview_output_connector_idx = connector_idx
		preview_output_node = graph_node
	else:
		preview_input_node = graph_node
		preview_input_connector_idx = connector_idx
	
	preview_line.visible = true
	_refresh_preview_line()
	
	
func _on_graph_node_3d_pointer_exit(graph_node: GraphNode3D, connector_idx, connector_type):
	print("exit", graph_node.id, connector_idx)
	preview_stayed_in_start_connector = false
	if preview_start_connector == null: return
	if preview_start_connector == connector_type: return
	
	if preview_start_connector == Connector.ConnectorType.InputConnector:
		preview_output_connector_idx = -1
		preview_output_node = null
	else:
		preview_input_node = null
		preview_input_connector_idx = -1
	
	preview_line.visible = false


func _on_graph_node_3d_moved(graph_node:GraphNode3D):
	if graph_node == preview_input_node or graph_node == preview_output_node:
		_refresh_preview_line()


func _create_connection(input_node: GraphNode3D, input_connector_idx: int, output_connector_idx: int, output_node: GraphNode3D):
	var connection = Connection.new()
	connection.input_connector_idx = input_connector_idx
	connection.input_node = input_node
	connection.output_node = output_node
	connection.output_connector_idx = output_connector_idx
	
	connection.line = line_scene.instantiate()
	$LinesParent.add_child(connection.line)
	connection.refresh_connection_line()
	
	var connections_to_remove: Array[Connection] = connections.filter(
		func(connection): return connection.input_node == input_node and connection.input_connector_idx == input_connector_idx
	)
		
	for connection_to_remove in connections_to_remove:
		connection_to_remove.destroy()
		connections.erase(connection_to_remove)
	
	connections.append(connection)
	_save_data()
	
	
func _refresh_preview_line():
	if !preview_line.visible: return
	preview_line.set_points(
		preview_input_node.get_connector_position(Connector.ConnectorType.InputConnector, preview_input_connector_idx),
		preview_output_node.get_connector_position(Connector.ConnectorType.OutputConnector, preview_output_connector_idx)
	)


class Connection:
	var input_node: GraphNode3D
	var output_node: GraphNode3D
	var input_connector_idx: int
	var output_connector_idx: int
	var line: Line3D
	
	func refresh_connection_line():
		line.set_points(
			input_node.get_connector_position(Connector.ConnectorType.InputConnector, input_connector_idx),
			output_node.get_connector_position(Connector.ConnectorType.OutputConnector, output_connector_idx)
		)
	
	func destroy():
		line.queue_free()


enum WorkState {Editor, Gameplay}
