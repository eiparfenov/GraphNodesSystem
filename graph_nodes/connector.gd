extends Control
class_name Connector


signal pointer_entered(connector_idx: int, connector_type: ConnectorType)
signal pointer_exited(connector_idx: int, connector_type: ConnectorType)
signal pointer_down(connector_idx: int, connector_type: ConnectorType)
signal pointer_up(connector_idx: int, connector_type: ConnectorType)

var idx: int
var connector_type: ConnectorType

func _on_panel_mouse_entered():
	pointer_entered.emit(idx, connector_type)


func _on_panel_mouse_exited():
	pointer_exited.emit(idx, connector_type)

func _on_panel_gui_input(event):
	if !event is InputEventMouseButton: return
	event = event as InputEventMouseButton
	if event.button_index != MOUSE_BUTTON_LEFT: return
	if event.pressed:
		pointer_down.emit(idx, connector_type)
	else:
		pointer_up.emit(idx, connector_type)


enum ConnectorType{InputConnector, OutputConnector}
