extends Node2D

var recent_block : Block = null
var recent_pin : Pin = null
var recent_connection : Connection = null
enum{MODE_IDLE, MODE_DND, MODE_CONNECT, MODE_SEL_BB}
var editor_mode: int = MODE_IDLE
var selbb_start_point: Vector2 = Vector2.ZERO
var sel_bb: Rect2
const COLOR_SEBB = Color(1.0, 1.0, 1.0, 0.1)

var selections : Array = []

var con_inst : PackedScene
var blk_inst : PackedScene

func get_actual_cursor():
	#FIXME: calculate cursor
	return get_global_mouse_position()
	
func _draw():
	if editor_mode == MODE_SEL_BB:
		draw_rect(sel_bb, COLOR_SEBB)

func _ready():
	con_inst = load("res://connection.tscn")
	blk_inst = load("res://block.tscn")

func pick_item(pos: Vector2):
	for i in range($blocks.get_child_count()-1, -1, -1):
		var block : Block =  $blocks.get_child(i)
		var pick = block.pickable()
		if pick == Block.PICK_BLOCK:
			editor_mode = MODE_DND
			$blocks.move_child(block, -1) #show
			recent_block = block
			if not block in selections:
				deselect()
				selections.append(recent_block)
			recent_block.select()
			
			return
		elif pick == Block.PICK_INOUT:
			editor_mode = MODE_CONNECT
			recent_block = block
			recent_pin = block.get_acitve_pin()
			var new_connection : Connection = con_inst.instantiate()
			$connections.add_child(new_connection)
			recent_pin.attach_new_connection(new_connection)
			recent_connection = new_connection
			return
			
	for i in range($connections.get_child_count()-1, -1, -1):
		var conn : Connection = $connections.get_child(i)
		if conn.pick_select(pos):
			selections.append(conn)
			return
			
	editor_mode = MODE_SEL_BB
	selbb_start_point = get_actual_cursor()

func drop_item(pos: Vector2):
	var found: bool = false
	for i in range($blocks.get_child_count()-1, -1, -1):
		var block : Block =  $blocks.get_child(i)
		#skip same block loop
		if block == recent_block:
			continue 
		var pick = block.pickable()
		if pick == Block.PICK_INOUT:
			var target_pin : Pin = block.get_acitve_pin()
			#skip in-to-in or out-to-out
			if target_pin.mode == recent_pin.mode:
				continue 
			#check same connections in in and in out
			var skip = false
			for conn in recent_pin.connections:
				if conn in target_pin.connections:
					skip = true
					break
			if skip:
				continue
			target_pin.attach_connection(recent_connection)
			return true
	return false
	
func deselect():
	for s in selections:
		s.deselect()
	selections.clear()
			
func select(pos: Vector2):
	deselect()
	for i in range($connections.get_child_count()-1, -1, -1):
		var conn : Connection = $connections.get_child(i)
		if conn.pick_select(pos):
			selections.append(conn)
			break

func _input(event):
	if event is InputEventKey:
		if event.physical_keycode == KEY_DELETE and event.pressed:
			for s in selections:
				s.queue_free()
			selections.clear()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pick_item(get_actual_cursor())
				if editor_mode == MODE_IDLE:
					select(get_actual_cursor())
			else:
				if editor_mode == MODE_CONNECT:
					if not drop_item(get_actual_cursor()):
						var new_block : Block = blk_inst.instantiate()
						$blocks.add_child(new_block)
						new_block.position = get_actual_cursor()
						new_block.get_oposite_pin(recent_pin).attach_connection(recent_connection)
				elif editor_mode == MODE_SEL_BB:
					sel_bb = Rect2(0,0,0,0)
					queue_redraw()
				editor_mode = MODE_IDLE

	if event is InputEventMouseMotion:
		if editor_mode == MODE_DND:
			for selblk in selections:
				if selblk is Block:
					selblk.position += event.relative
		elif editor_mode == MODE_CONNECT:
			recent_pin.update_connection_bezier_points(recent_connection, get_actual_cursor())
		elif editor_mode == MODE_SEL_BB:
			#calculate bb
			var cur_pos: Vector2 = get_actual_cursor()
			sel_bb = Rect2(
				min(cur_pos.x, selbb_start_point.x),
				min(cur_pos.y, selbb_start_point.y),
				abs(cur_pos.x - selbb_start_point.x),
				abs(cur_pos.y - selbb_start_point.y)
			)
			queue_redraw()
			
			
