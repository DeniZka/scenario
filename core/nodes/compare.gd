class_name CompareGraphNode
extends MyGraphNode

enum{IDTIME, IDTIMEMODEL, IDTIMER, IDCONST, IDVAR, IDSIGNAL}
const CHILD_TIME = 0
const CHILD_LINEED = 1

@onready var op1 = $HBoxContainer/OBA
@onready var op2 = $HBoxContainer/OBB
@onready var op = $HBoxContainer/OBOp
@onready var vb1 = $VB1
@onready var vb2 = $VB2

var token_ready : bool = false
var _token : ScenarioToken = null

# Called when the node enters the scene tree for the first time.
func _ready():
	seq_pipe.mode = ScenarioPipeOrganizer.MODE_AWAIT
	super._ready()
	
func get_value(vb: VBoxContainer):
	var op_idx = 0
	if vb == vb1:
		op_idx = op1.selected
	else:
		op_idx = op2.selected
		
	#TODO: cache static values (const, time)
		
	if op_idx == IDTIME:
		var sbs : Array = vb.get_child(CHILD_TIME).get_children()
		return sbs[0].value * 3600 + sbs[1].value * 60 + sbs[2].value
	elif op_idx == IDTIMER:
		var s: String = vb.get_child(CHILD_LINEED).text
		if not s:
			return NAN
		var timer : Timer = _token.get_timer(s)
		if not timer:
			return NAN
		return timer.wait_time - timer.time_left

func do_compare(val1: float, val2: float):
	print("val1 ", val1,  "  val2 ", val2)
	match op.selected:
		0: return val1 == val2
		1: return val1 != val2
		2: return val1 > val2
		3: return val1 >= val2
		4: return val1 < val2
		5: return val1 <= val2
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if token_ready:
		#check token taken with some one else
		if not seq_pipe.has():
			token_ready = false
			set_slot_color_left(0, Color(1,1,1))
			return
		#pick token for check
		var check_ok : bool = false
		_token = seq_pipe.pick()
		if do_compare(get_value(vb1), get_value(vb2)):
			set_slot_color_left(0, Color(1,1,1))
			var token : ScenarioToken = seq_pipe.pop()
			if token:
				set_slot_color_right(0, CLR_INPUT_ANY)
				shared_pipe.push(token)
	
func _on_seq_token_ready():
	token_ready = true
	set_slot_color_left(0, CLR_INPUT_ANY)

func hideall(vb: VBoxContainer):
	for child in vb.get_children():
		child.hide()

func swap_item(vb: VBoxContainer, id: int):
	hideall(vb)
	if id == IDTIME:
		vb.get_child(CHILD_TIME).show()
	elif id == IDTIMER:
		vb.get_child(CHILD_LINEED).show()
	
func _on_oba_item_selected(index):
	swap_item(vb1, index)

func _on_obb_item_selected(index):
	swap_item(vb2, index)
