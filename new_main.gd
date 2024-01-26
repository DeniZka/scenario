class_name ScenarioPlayer
extends Control

var colors : Array[StyleBoxFlat] = []
@onready var capt_editor : VBoxContainer = $HSplitContainer/VSplitContainer/ScrollContainer2/DefaultNodeProperties/VBNodeCaption
@onready var desc_editor : VBoxContainer = $HSplitContainer/VSplitContainer/ScrollContainer2/DefaultNodeProperties/VBDescription
@onready var clr_picker : VBoxColorPicker = $HSplitContainer/VSplitContainer/ScrollContainer2/DefaultNodeProperties/VBColorPicker
@onready var input_editor : VBoxContainer = $HSplitContainer/VSplitContainer/ScrollContainer2/DefaultNodeProperties/VBActivationMode
@onready var output_editor : VBoxContainer = $HSplitContainer/VSplitContainer/ScrollContainer2/DefaultNodeProperties/VBExitMode
@onready var editor : GraphEdit = $HSplitContainer/GraphEdit
var last_selected : GraphNode


func _ready():
	var default_color : StyleBoxFlat = StyleBoxFlat.new()
	var clr : Color = Color(0.5,0.5,0.5,0.5)
	default_color.bg_color = clr
	colors.append(default_color)
	clr_picker.add_color(clr)


func _on_graph_edit_node_selected(node):
	last_selected = node
	#capt_editor.set_caption(node.get_caption())
	#desc_editor.set_description(node.get_description())


func _on_graph_edit_node_deselected(node):
	if node == last_selected:
		last_selected = null
		capt_editor.set_caption("")
		desc_editor.set_description("")
	pass # Replace with function body.


func _on_vb_color_picker_node_color_selected(idx):
	editor.set_selected_color(colors[idx])


func _on_vb_colors_color_added(color):
	var new_color : StyleBoxFlat = StyleBoxFlat.new()
	new_color.bg_color = color
	colors.append(new_color)
	clr_picker.add_color(color)


func _on_vb_colors_color_changed(index, color):
	colors[index].bg_color = color
	clr_picker.change_color(index, color)


func _on_vb_colors_color_removed(index):
	#colors[index].free() #FIXME: some bugs with nodes if removed???
	editor.clear_nodes_color(colors[index])
	colors.remove_at(index)
	clr_picker.remove_color(index)


func _on_vb_node_caption_caption_changed(new_text):
	if last_selected:
		$HSplitContainer/GraphEdit.set_node_caption(last_selected, new_text)


func _on_vb_description_description_changed(text):
	if last_selected:
		last_selected.set_description(text)


func _on_vb_activation_mode_input_mode_changed(mode):
	if last_selected:
		last_selected.input_mode = mode


func _on_vb_exit_mode_output_mode_changed(mode):
	if last_selected:
		last_selected.output_mode = mode


#push-pop testing

func _on_box_container_pop_1_pressed():
	if last_selected:
		last_selected.pop1()
	pass # Replace with function body.


func _on_box_container_pop_2_pressed():
	if last_selected:
		last_selected.pop2()
	pass # Replace with function body.


func _on_box_container_push_1_pressed():
	if last_selected:
		last_selected.push1()
	pass # Replace with function body.


func _on_box_container_push_2_pressed():
	if last_selected:
		last_selected.push2()
	pass # Replace with function body.
