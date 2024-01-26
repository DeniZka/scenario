extends VBoxContainer

signal caption_changed(new_text: String)
var disble_callback : bool = false

func set_caption(text_string: String):
	disble_callback = true
	$CaptionEdit.text = text_string
	disble_callback = false

func _on_caption_edit_text_changed(new_text):
	if not disble_callback:
		caption_changed.emit(new_text)
