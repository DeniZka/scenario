class_name ColorItem
extends HBoxContainer

signal color_changed(obj: ColorItem, color: Color)
signal remove_called(obj: ColorItem)

@export var default : bool = false:
	set(val):
		default = val
		if not is_node_ready(): await ready
		if val:
			$BtnKill.visible = false
			$ColorPickerButton.disabled = true
		else:
			$BtnKill.visible = true
			$ColorPickerButton.disabled = false


func _on_color_picker_button_color_changed(color):
	color_changed.emit(self, color)

func _on_btn_kill_pressed():
	remove_called.emit(self)


func _on_color_picker_button_picker_created():
	var picker: ColorPicker = $ColorPickerButton.get_picker()
	picker.color_mode = ColorPicker.MODE_OKHSL
