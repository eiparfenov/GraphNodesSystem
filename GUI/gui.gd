extends Node3D
class_name GUI

@export var ppu: float = 100

@onready var display = $Display
@onready var area = $Area
@onready var viewport: SubViewport = $Viewport

var mesh_size: Vector2 = Vector2()

var mouse_entered: bool = false
var mouse_held: bool = false
var mouse_inside: bool = false

var last_mouse_pos_3D = null
var last_mouse_pos_2D = null

var pointer_pos_3D = null


func _ready():
	viewport.set_process_input(true)
	
	area.scale.x = viewport.size.x / ppu
	display.scale.x = viewport.size.x / ppu
	
	area.scale.y = viewport.size.y / ppu
	display.scale.y = viewport.size.y / ppu
	
	
func handle_mouse(event):
	mesh_size = display.mesh.size
	
	var mouse_pos3D = pointer_pos_3D
	
	mouse_inside = mouse_pos3D != null
	
	if mouse_inside:
		mouse_pos3D = area.global_transform.affine_inverse() * mouse_pos3D
		last_mouse_pos_3D = mouse_pos3D
	else:
		mouse_pos3D = last_mouse_pos_3D
		if mouse_pos3D == null:
			mouse_pos3D = Vector3.ZERO
	
	var mouse_pos2D = Vector2(mouse_pos3D.x, -mouse_pos3D.y)
	
	#convert from -meshsize/2 to meshsize/2
	mouse_pos2D.x += mesh_size.x / 2
	mouse_pos2D.y += mesh_size.y / 2
	#convert to 0 to 1
	mouse_pos2D.x = mouse_pos2D.x / mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / mesh_size.y
	#convert to viewport range 0 to veiwport size
	mouse_pos2D.x = mouse_pos2D.x * viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * viewport.size.y
	
	event.position = mouse_pos2D
	event.global_position = mouse_pos2D
	
	if event is InputEventMouseMotion:
		if last_mouse_pos_2D == null:
			event.relative = Vector2(0, 0)
		else:
			event.relative = mouse_pos2D - last_mouse_pos_2D
		
	last_mouse_pos_2D = mouse_pos2D
	
	viewport.push_input(event)
	
