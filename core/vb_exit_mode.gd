extends VBoxContainer


signal output_mode_changed(mode: int)


func set_output_mode(mode: int):
	$OptionButton.selected = mode


func _on_option_button_item_selected(index):
	output_mode_changed.emit(index)
