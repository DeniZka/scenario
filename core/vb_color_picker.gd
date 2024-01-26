class_name VBoxColorPicker
extends VBoxContainer

@onready var clr_grid : GridContainer = $ScrollContainer/GridContainer

signal node_color_selected(idx: int)

@onready var color_btn_scene : PackedScene = load("res://core/color_button.tscn")

func _on_grid_container_resized():
	if not is_node_ready(): await  ready
	clr_grid.columns = clr_grid.size.x / 36
	pass # Replace with function body.

func add_color(color: Color):
	var btn: PickColorButton = color_btn_scene.instantiate()
	clr_grid.add_child(btn)
	btn.color = color
	btn.pressed_self.connect(_on_button_pressed_self)
	
func clear():
	for btn in clr_grid.get_children():
		btn.queue_free()
	
func remove_color(idx: int):
	var btns : Array = clr_grid.get_children()
	btns[idx].queue_free()

func change_color(idx: int, color: Color):
	var btns : Array = clr_grid.get_children()
	btns[idx].color = color
	
func _on_button_pressed_self(btn: PickColorButton):
	var btns : Array = clr_grid.get_children()
	for i in range(btns.size()):
		if btns[i] == btn:
			node_color_selected.emit(i)
			break

