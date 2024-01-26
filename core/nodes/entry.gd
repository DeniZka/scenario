class_name EntryGraphNode
extends MyGraphNode

var pipe: ScenarioSharedPipe = ScenarioSharedPipe.new(name)

# Called when the node enters the scene tree for the first time.
func _ready():
	var title_hbox : HBoxContainer = get_titlebar_hbox()
	var label : Label = title_hbox.get_child(0)
	#TODO: colorize

func start():
	var token : ScenarioToken = ScenarioToken.new()
	pipe.push(token)

func poop_info():
	#print(name, "inputs: ", inputs.size(), " outputs: ", outputs.size())
	pass
	
func get_pipe(port: int):
	return pipe
