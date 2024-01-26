class_name GlobalColors
extends VBoxContainer

@onready var color_box : BoxContainer = $VBoxContainer/ScrollContainer/ColorItems
@onready var color_item : PackedScene = load("res://core/hb_color_item.tscn")

signal color_added(color: Color)
signal color_removed(index: int)
signal color_changed(index: int, color: Color)

func _ready():
	for item in color_box.get_children():
		item.color_changed.connect(_on_item_color_changed)
		item.remove_called.connect(_on_item_remove_called)


func _on_btn_add_pressed():
	var cbtn : ColorItem = color_item.instantiate()
	color_box.add_child(cbtn)
	cbtn.color_changed.connect(_on_item_color_changed)
	cbtn.remove_called.connect(_on_item_remove_called)
	color_added.emit(Color(1,1,1,1))


func _on_item_color_changed(item: ColorItem, color: Color):
	var clrs : Array = color_box.get_children()
	for i in range(clrs.size()):
		if clrs[i] == item:
			color_changed.emit(i, color)
			return

func _on_item_remove_called(item: ColorItem):
	var clrs : Array = color_box.get_children()
	for i in range(clrs.size()):
		if clrs[i] == item:
			color_removed.emit(i)
			break
	color_box.remove_child(item)
	item.queue_free()
	
	
func get_color_count():
	return color_box.get_child_count()

func _on_header_button_toggled(toggled_on):
	$VBoxContainer.visible = toggled_on
	pass # Replace with function body.
