class_name GraphPopupMenu
extends PopupMenu

enum{MODE_ANY, MODE_INPUT, MODE_OUTPUT}

signal node_creation_selected(mode: int, node: String, position: Vector2, new_node_type: int)
signal node_createion_discarded()

var io_node: String = ""
var io_pos: Vector2 = Vector2.ZERO
var io_mode: int = 0

func custom_popup(mode: int, pos: Vector2, node: String = ""):
	position = pos
	io_node = node
	io_pos = pos
	io_mode = mode
	set_item_disabled(MODE_INPUT, false)
	set_item_disabled(MODE_OUTPUT, false)
	if mode == MODE_INPUT:
		set_item_disabled(MODE_OUTPUT, true)
	elif mode == MODE_OUTPUT:
		set_item_disabled(MODE_INPUT, true)
	popup()

func _on_index_pressed(index):
	node_creation_selected.emit(io_mode, io_node, io_pos, index)

func _on_popup_hide():
	node_createion_discarded.emit()
