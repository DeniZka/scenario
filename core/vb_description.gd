extends VBoxContainer

signal description_changed(text: String)
var disble_callback : bool = false

func set_description(text: String):
	disble_callback = true
	$TextEdit.text = text
	disble_callback = false

func _on_text_edit_text_changed():
	if not disble_callback:
		description_changed.emit($TextEdit.text)
	pass # Replace with function body.
