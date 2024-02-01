class_name MixGraphNode
extends MyGraphNode


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	seq_pipe.mode = ScenarioPipeOrganizer.MODE_SYNCHRONIZE

func _on_seq_fill_changed(capacity_status: int):
	if capacity_status == ScenarioPipeOrganizer.FILL_EMPTY:
		set_slot_color_left(0, CLR_INACTIVE_SLOT)
	elif capacity_status == ScenarioPipeOrganizer.FILL_EXIST:
		set_slot_color_left(0, CLR_ACTIVE_SHARED_SLOT)
	elif capacity_status == ScenarioPipeOrganizer.FILL_ALMOST_FULL:
		set_slot_color_left(0, CLR_INPUT_ALL)

func _on_seq_token_ready():
	set_slot_color_left(0, Color(1,1,1))
	set_slot_color_right(0, CLR_INPUT_ANY)
	shared_pipe.push(seq_pipe.pop())

func _on_spin_box_value_changed(value):
	seq_pipe.sync_limit = value
