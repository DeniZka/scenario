extends VBoxContainer

signal input_mode_changed(mode: int)

func _on_option_button_item_selected(index):
	input_mode_changed.emit(index)

func set_input_mode(mode: int):
	$OptionButton.select(mode)
