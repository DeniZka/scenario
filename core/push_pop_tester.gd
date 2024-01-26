extends BoxContainer

signal push1_pressed()
signal push2_pressed()
signal pop1_pressed()
signal pop2_pressed()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pop_1_pressed():
	pop1_pressed.emit()
	pass # Replace with function body.


func _on_pop_2_pressed():
	pop2_pressed.emit()
	pass # Replace with function body.


func _on_push_1_pressed():
	push1_pressed.emit()
	pass # Replace with function body.


func _on_push_2_pressed():
	push2_pressed.emit()
	pass # Replace with function body.
