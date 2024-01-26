@tool
class_name Block
extends Node2D

var in_inout: bool = false
var active_pin: Pin = null
var in_bound: bool = false
var sel_rect : RectangleShape2D = null
enum{STATE_AWAIT, STATE_EXECUTE}
var state: int = STATE_AWAIT

const COLOR_NORMAL = Color(0.7, 0.7, 0.7)
const COLOR_SELECT = Color(1.0, 1.0, 1.0)

@export var block_name: String = "":
	set(val):
		block_name = val
		if not is_node_ready(): await ready
		$Label.text = val
		#TODO: check size of Label and resize slef

enum{CP_NONE, CP_ANY, CP_ALL}
@export_enum("No:0", "Any:1", "All:2") var checkpoint: int = CP_NONE:
	set(val):
		checkpoint = val
		if not is_node_ready(): await ready
		if checkpoint + CP_ALL:
			$In.input_trigger = Pin.MODE_IN_ANY
		else:
			$in.input_trigger = Pin.MODE_IN_ANY
		
#@export var stop_pass: bool = true #call stop chain to prevous blocks
#@export var stop_call: bool = false #call stop chain if trigged

func _ready():
	set_notify_local_transform(true)
	sel_rect = RectangleShape2D.new()
	$Selection/ShapeRect.shape = sel_rect
	#FIXME: resize due to Label resizing
	sel_rect.size = Vector2(96, 48)
	
func _notification(what):
	if what == NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		$Out.update_connections(position)
		$In.update_connections(position)
		
func _process(delta):
	if state == STATE_AWAIT:
		return
	#TODO: execute checking and setting
	$Out.call_exec()
	#state == STATE_AWAIT
	
func _on_inout_mouse_down(obj, state):
	pass # Replace with function body.

func _on_inout_mouse_entered(obj, my_local_pos):
	active_pin = obj
	in_inout = true

func _on_inout_mouse_leave(obj):
	in_inout = false

func _on_selection_input_event(viewport, event, shape_idx):
	get_children()
	if in_inout: #pass when clicked in inout pin
		return

func _on_selection_mouse_entered():
	in_bound = true

func _on_selection_mouse_exited():
	in_bound = false

func is_in_bound(pos: Vector2):
	#print(get_viewport_rect())
	if not in_inout:
		return in_bound
	else:
		return false

enum{PICK_NONE, PICK_INOUT, PICK_BLOCK}
func pickable():
	if in_inout: #high priority
		return PICK_INOUT
	elif in_bound:
		return PICK_BLOCK
	else:
		return PICK_NONE

func get_acitve_pin():
	if in_inout:
		return active_pin
	else:
		return null

func _on_out_stop_called():
	if checkpoint == CP_NONE:
		$In.call_stop()


func _on_in_exec_called():
	state = STATE_EXECUTE

func select():
	$Outline.default_color = COLOR_SELECT
	pass

func deselect():
	$Outline.default_color = COLOR_NORMAL
	
func get_oposite_pin(sample: Pin):
	if sample.mode == Pin.MODE_IN:
		return $Out
	else:
		return $In

func get_rect():
	"res://block.tscn::RectangleShape2D_cysfg"
	return 
