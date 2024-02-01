class_name SpreadGraphNode
extends MyGraphNode

signal slot_removed(obj: GraphNode, idx: int)
#override GraphNodePipe with banch of pipes
@onready var pipes: Array[ScenarioSharedPipe] = [ScenarioSharedPipe.new(self.name)]

var pre_value: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	seq_pipe.mode = ScenarioPipeOrganizer.MODE_OVERWRITE
	pipes[0].token_taken.connect(_on_shared_token_taken)
	
func _on_seq_token_ready():
	var token : ScenarioToken = seq_pipe.pop()
	if token:
		for i in range(pipes.size()):
			set_slot_color_right(i, CLR_INPUT_ANY)
			pipes[i].push(token)
	
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
			var pipe: ScenarioSharedPipe = ScenarioSharedPipe.new(self.name)
			pipe.token_taken.connect(_on_shared_token_taken)
			pipes.append(pipe)
	if pre_value > value:
		for i in range(pre_value - value):
			var node : Node = get_child(-1)
			set_slot_enabled_left(pre_value - i - 1, false)
			node.queue_free()
			#remove_child(node)
			slot_removed.emit(self, pre_value - i - 1)
			pipes.erase(-1)
	print(value)
	var pc = get_output_port_count()
	print("Port count ", pc)
	pre_value = value
	
func _on_shared_token_taken(pipe: ScenarioPipe, empty: bool):
	for i in range(pipes.size()):
		if pipes[i] == pipe:
			set_slot_color_right(i, CLR_INACTIVE_SLOT)
	
func _on_slot_removed(obj, idx):
	#print("removed ", idx)
	pass # Replace with function body.

func get_pipe(port: int):
	return pipes[port]
