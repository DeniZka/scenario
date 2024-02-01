class_name EntryGraphNode
extends MyGraphNode

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	var title_hbox : HBoxContainer = get_titlebar_hbox()
	var label : Label = title_hbox.get_child(0)
	#TODO: colorize

func start(token: ScenarioToken):
	set_slot_color_right(0, CLR_INPUT_ANY)
	shared_pipe.push(token)
