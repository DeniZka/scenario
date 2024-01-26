@tool
class_name PickColorButton
extends Button

signal pressed_self(obj: PickColorButton)

@export var color: Color = Color(1,1,1,1):
	set(val):
		color = val
		$ColorRect.color = val
		

func set_color(clr: Color):
	color = clr

func _on_pressed():
	pressed_self.emit(self)
