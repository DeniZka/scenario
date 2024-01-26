@tool
class_name Pin
extends Node2D

#signal to correct curve creation
signal mouse_entered(obj: Pin, my_local_pos: Vector2)
signal mouse_leave(obj: Pin)
signal mouse_down(obj: Pin, state: bool)

signal stop_called() #to block
signal exec_called() #to block

var connections: Array[Connection] = []

var attached_network : Curve2D = null

enum{MODE_IN, MODE_OUT}
@export_enum("Input:0", "Output:1") var mode: int = MODE_IN:
	set(val):
		mode = val
		if not is_node_ready(): await ready
		if mode == MODE_IN:
			$Mode/In.visible = true
			$Mode/Out.visible = false
		else:
			$Mode/In.visible = false
			$Mode/Out.visible = true
			
enum{MODE_IN_ANY, MODE_IN_ALL}
@export_enum("Any:0", "All:1") var input_trigger: int = MODE_IN_ANY
			
func update_connections(block_pos: Vector2):
	for conn in connections:
			conn.set_point_pos(mode, block_pos + position)

func update_connection_bezier_points(conn: Connection, opposit_point_pos: Vector2):
	if mode == MODE_IN:
		conn.set_point_pos(MODE_OUT, opposit_point_pos)
	else:
		conn.set_point_pos(MODE_IN, opposit_point_pos)

func _on_in_sensor_mouse_entered():
	mouse_entered.emit(self, position)
	
func _on_in_sensor_mouse_exited():
	mouse_leave.emit(self)
	
func _on_in_sensor_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_down.emit(self, event.pressed)

func get_attached_network():
	pass
	
func call_stop():
	for conn in connections:
		conn.call_stop()
		
func call_exec():
	for conn in connections:
		conn.call_exec()
	
func _manage_new_connection(connection: Connection):
	connection.remove_called.connect(on_connection_remove_called)
	connection.exec_called.connect(_on_connection_exec_called)
	connections.append(connection)
	
func attach_connection(connection: Connection):
	_manage_new_connection(connection)
	connection.set_point_pos(mode, 	get_parent().position + position)
	
func attach_new_connection(connection: Connection):
	_manage_new_connection(connection) 
	connection.set_point_pos(MODE_IN, get_parent().position + position)
	connection.set_point_pos(MODE_OUT, get_parent().position + position)
	
func _on_connection_exec_called():
	if MODE_IN_ANY:
		exec_called.emit()
	else:
		var all_active = true
		for conn in connections:
			if not conn.is_active():
				all_active = false
				break
		if all_active:
			exec_called.emit()
			
func on_connection_remove_called(connection: Connection):
	for conn in connections:
		if conn == connection:
			connections.erase(conn)
			break

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for conn in connections:
			conn.queue_free()
