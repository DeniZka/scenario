class_name SpreadGraphNode
extends MyGraphNode

signal slot_removed(obj: GraphNode, idx: int)
@onready var pipes: Array[ScenarioSharedPipe] = [ScenarioSharedPipe.new(self.name)]

var pre_value: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_slot_updated(slot_index):
	print("SLOT ", slot_index)
	pass # Replace with function body.


func _on_spin_box_value_changed(value):
	#TODO: open slots
	if pre_value < value:
		for i in range(value - pre_value):
			var slot_ctrl : Label = Label.new()
			add_child(slot_ctrl)
			slot_ctrl.text = "asdf"
			set_slot_enabled_right(pre_value + i, true)
			pipes.append(ScenarioSharedPipe.new(self.name))
	if pre_value > value:
		for i in range(pre_value - value):
			var node : Node = get_child(-1)
			node.queue_free()
			remove_child(node)
			slot_removed.emit(self, pre_value - i - 1)
			pipes.erase(-1)
	print(value)
	pre_value = value
	
	
func _on_slot_removed(obj, idx):
	print("removed ", idx)
	pass # Replace with function body.

func get_pipe(port: int):
	return pipes[port]
