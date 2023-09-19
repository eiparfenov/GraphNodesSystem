extends RayCast3D

@export var temp_mov_speed: float
@onready var sphere_pointer: MeshInstance3D = $SpherePointer


var target: GUI = null:
	get: return target
	set(new_value):
		if target == new_value:
			return
		
		if target != null:
			target.mouse_held = false
			target.mouse_entered = false
			target.pointer_pos_3D = null
			target.handle_mouse(InputEventMouseMotion.new())
		
		target = new_value
		
		if target != null:
			target.mouse_entered = true
			target.mouse_held = button_pressed

var button_pressed: bool = false:
	get: return button_pressed
	set(value):
		if target == null:
			return
		elif not button_pressed and value:
			var event = InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = true
			target.handle_mouse(event)
		elif button_pressed and not value:
			var event = InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = false
			target.handle_mouse(event)
		
		button_pressed = value
		
		target.mouse_held = button_pressed
		

func _process(delta):
	_temp_movement(delta)
	
	var col = get_collider()
	var current_target: GUI = null
	if col != null:
		current_target = col.get_parent() as GUI
	target = current_target
	if target != null:
		target.pointer_pos_3D = get_collision_point()
	
	sphere_pointer.visible = target != null
	if target != null:
		sphere_pointer.global_position = get_collision_point()
	
	if target != null:
		target.handle_mouse(InputEventMouseMotion.new())
	
	button_pressed = Input.is_key_pressed(KEY_Z)
	

func _temp_movement(delta):
	if Input.is_key_pressed(KEY_W): global_position += Vector3.UP * temp_mov_speed * delta
	if Input.is_key_pressed(KEY_S): global_position += Vector3.DOWN * temp_mov_speed * delta
	if Input.is_key_pressed(KEY_A): global_position += Vector3.LEFT * temp_mov_speed * delta
	if Input.is_key_pressed(KEY_D): global_position += Vector3.RIGHT * temp_mov_speed * delta
