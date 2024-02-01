extends GraphEdit

###Achtung USE managed_discocnnect / managed_connect

var copies: Array[GraphNode]
var selection_cursor : Vector2
var colors: Array[StyleBoxFlat]
var in_empty_new_node : GraphNode = null

#recast for newly created input or output node
var input_node_state : Dictionary = {
	"color": null,
	"caption": "",
}
var output_node_state : Dictionary = {
	"color": null,
	"caption": "",
}

@onready var node_res : PackedScene = load("res://my_graph_node.tscn")
var stop_drag_connection = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var menu : HBoxContainer = get_menu_hbox()
	var play : Button = Button.new()
	menu.add_child(play)
	play.text = "Play"
	play.pressed.connect(_on_play_pressed)
	for node in get_children():
		if node is SpreadGraphNode:
			node.slot_removed.connect(_on_spreadnode_slot_removed)
			
func _on_spreadnode_slot_removed(node: MyGraphNode, idx: int):
	#check connection exists
	for conn in get_connection_list():
		if conn["from_node"] == node.name and conn["from_port"] == idx:
			disconnect_node(conn["from_node"], conn["from_port"], conn["to_node"], conn["to_port"])


func _on_play_pressed():
	#get entrance nodes
	var token : ScenarioToken = ScenarioToken.new()
	for node in get_children():
		if node is MyGraphNode:
			node.reset()
	for node in get_children():
		if node is EntryGraphNode:
			node.start(token)

func _input(event):
	if event is InputEventKey:
		if (event as InputEventKey).keycode == KEY_SPACE and event.pressed:
			pass


func managed_connect(from_node: String, to_node: String, from_port: int =0, to_port: int = 0):
	connect_node(from_node, from_port, to_node, to_port)
	#set managing connection
	var node : MyGraphNode = get_node(from_node)
	node.manage_output(to_node)
	var pipe: ScenarioPipe = node.get_pipe(from_port)
	node = get_node(to_node)
	node.manage_input(pipe)
	
func managed_disconnect(from_node: String, to_node: String, from_port: int =0, to_port: int = 0):
	disconnect_node(from_node, from_port, to_node, to_port)
	var node : MyGraphNode = get_node(from_node)
	node.unmanage_output(to_node)
	node = get_node(to_node)
	node.unmanage_input(from_node)

#central function to connect 
func _on_connection_request(from_node, from_port, to_node, to_port):
	var clist : Array[Dictionary] = get_connection_list()
	#TODO: second attempt to connect use as disconnect
	#for conn in clist:
		#if conn["from_node"] == from_node and conn["to_node"] == to_node:
			#managed_disconnect(from_node, to_node)
			#return
	managed_connect(from_node, to_node, from_port, to_port)
	
	
#central function to disconnect disconnect
func _on_disconnection_request(from_node, from_port, to_node, to_port):
	var conn_list = get_connection_list()
	#multiple connections
	#get connection where target is disconnecting node
	
	#TODO: UNMAGAE CONNECTIONS FOR NODES
	
	#get nodes connected to target node
	var true_conn_list : Array[Dictionary] = []
	for conn in conn_list:
		if conn["to_node"] == to_node:
			true_conn_list.append(conn)
			
	
	
	#FIXME: multiple connections disconnectin bug
	#if only one
	if true_conn_list.size() == 1:
		managed_disconnect(from_node, to_node)
		return
	
	#check connection is single
	var selections = get_selected()
	if selections.size() == 1:
		for conn in true_conn_list:
			if selections[0].name == conn["from_node"]:
				managed_disconnect(conn["from_node"], to_node)
				break
	#stop drag due to cross disconnection bug
	stop_drag_connection = true


func try_to_pick_connection():
	print("pick connection")


func _on_gui_input(event):
	pass


func _unhandled_input(event):
	#print("unhandled")
	pass


func _on_connection_drag_started(from_node, from_port, is_output):
	if stop_drag_connection:
		force_connection_drag_end()
		stop_drag_connection = false


func get_selected():
	var sel_list: Array[GraphNode]
	for node in get_children():
		if node is GraphNode and node.selected:
			sel_list.append(node)
	return sel_list
	
	
func get_inputs():
	var ins: Array[GraphNode]
	for node in get_children():
		if node is MyGraphNode and node.io_type == MyGraphNode.IOTYPE_ENTRANCE:
			ins.append(node)
	return ins
	
	
func get_outputs():
	var outs: Array[GraphNode]
	for node in get_children():
		if node is MyGraphNode and node.io_type == MyGraphNode.IOTYPE_EXIT:
			outs.append(node)
	return outs


func _on_copy_nodes_request():
	copies.clear()
	var sel_list = get_selected()
	for node in sel_list :
		copies.append(node.duplicate())
	selection_cursor = get_local_mouse_position() #FIXME: on change


func _on_duplicate_nodes_request():
	#print("duplicate")
	pass


func _on_paste_nodes_request():
	for node in get_selected():
		node.selected = false
	for node_ref in copies:
		var new_node : GraphNode = node_ref.duplicate()
		add_child( new_node )
		new_node.position_offset += (get_local_mouse_position() - selection_cursor) / zoom


func _on_popup_request(position):
	$GraphPopupMenu.custom_popup(GraphPopupMenu.MODE_ANY, position)


func _on_delete_nodes_request(nodes):
	#remove connections either
	var conn_list = get_connection_list()
	for conn in conn_list:
		if conn["from_node"] in nodes or conn["to_node"] in nodes:
			managed_disconnect(conn["from_node"], conn["to_node"])
	#remove nodes
	for node in get_children():
		if node is GraphNode and node.name in nodes:
			node.queue_free()


func _on_graph_popup_menu_node_createion_discarded():
	in_empty_new_node = null
	pass # Replace with function body.


func _on_graph_popup_menu_node_creation_selected(mode: int, opos_node: String, in_pos: Vector2, new_node_type: int):
	var node : MyGraphNode = node_res.instantiate()
	add_child(node)
	node.io_type = new_node_type
	if new_node_type == MyGraphNode.IOTYPE_ENTRANCE:
		node.color = input_node_state["color"]
		node.set_caption(input_node_state["caption"])
	if new_node_type == MyGraphNode.IOTYPE_EXIT:
		node.color = output_node_state["color"]
		node.set_caption(output_node_state["caption"])
	node.position_offset = in_pos / zoom + scroll_offset  / zoom
	if mode == GraphPopupMenu.MODE_INPUT:
		_on_connection_request(opos_node, 0, node.name, 0)
	elif mode == GraphPopupMenu.MODE_OUTPUT:
		_on_connection_request(node.name, 0, opos_node, 0)


func _on_connection_to_empty(from_node, from_port, release_position):
	var cur = get_local_mouse_position()
	$GraphPopupMenu.custom_popup(GraphPopupMenu.MODE_INPUT, release_position, from_node)


func _on_connection_from_empty(to_node, to_port, release_position):
	$GraphPopupMenu.custom_popup(GraphPopupMenu.MODE_OUTPUT, release_position, to_node)


func clear_nodes_color(color: StyleBoxFlat):
	for node in get_children():
		if node is MyGraphNode and node.color == color:
			node.color = null


func set_selected_color(color: StyleBoxFlat):
	var sels : Array[GraphNode] = get_selected()
	var got_inputs : bool = false
	
	var got_outputs : bool = false
	
	for node in sels:
		node.color = color
		if node.io_type == MyGraphNode.IOTYPE_ENTRANCE:
			got_inputs = true
			input_node_state["color"] = color
		if node.io_type == MyGraphNode.IOTYPE_EXIT:
			got_outputs = true
			output_node_state["color"] = color
	if got_inputs:
		var ins : Array[GraphNode] = get_inputs()
		for node in ins:
			node.color = color
	if got_outputs:
		var outs : Array[GraphNode] = get_outputs()
		for node in outs:
			node.color = color

#temp function for checking
func _on_node_selected(node):
	#node.poop_info()
	pass
	
func set_node_caption(node, text):
	node.set_caption(text)
	if node is MyGraphNode and node.io_type == MyGraphNode.IOTYPE_ENTRANCE:
		input_node_state["caption"] = text
		var inputs : Array[GraphNode] = get_inputs()
		for inode in inputs:
			inode.set_caption(text)
	if node is MyGraphNode and node.io_type == MyGraphNode.IOTYPE_EXIT:
		output_node_state["caption"] = text
		var outputs : Array[GraphNode] = get_outputs()
		for onode in outputs:
			onode.set_caption(text)
