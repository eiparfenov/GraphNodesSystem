extends GUI
class_name GraphNode3D

@export var input_contract: Array[String]
@export var output_contract: Array[String]

@onready var node_ui: GraphNode3dUi = $Viewport/NodeUi


func _ready():
	node_ui.fill_node(input_contract, output_contract)
	viewport.size = Vector2(410, 10 + 50 * max(input_contract.size(), output_contract.size()))
	super()
