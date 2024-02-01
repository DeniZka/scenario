@tool
class_name  MyGraphNode
extends GraphNode
#TODO: change signal - to token
#oututps:
#offer token
#decleen offer

#inputs:
#incoming offers
#accept offer
const SEQ_PORT = 0
const SYNC_PORT = 1
@onready var seq_pipe: ScenarioPipeOrganizer = ScenarioPipeOrganizer.new(name, ScenarioPipeOrganizer.MODE_OVERWRITE)
const SHARED_PORT = 0
const SPREAD_PORT = 1
@onready var shared_pipe: ScenarioSharedPipe = ScenarioSharedPipe.new(name)

signal finish()

const CLR_INPUT_ALL = Color(1, 0.7, 0, 1)
const CLR_INPUT_ANY = Color(0, 0.7, 0, 1)
const CLR_INPUT_FIRST = Color(0, 0.7, 1, 1)
const CLR_INACTIVE_SLOT = Color(0.5, 0.5, 0.5)
const CLR_ACTIVE_SHARED_SLOT = Color(0.863, 0.494, 0.0)
const CLR_ACTIVE_SPREAD_SLOT = Color(0.286, 1.0, 1.0)

var prevoud_check_result : bool = false

@onready var color: StyleBoxFlat = null: 
	set(val):
		color = val
		if not is_node_ready(): await ready
		if val:
			add_theme_stylebox_override("panel", val) #titlebar
			add_theme_stylebox_override("panel_selected", val) # titlebar_selected
		else: #null
			remove_theme_stylebox_override("panel")
			remove_theme_stylebox_override("panel_selected")
enum{IOTYPE_PASS, IOTYPE_EXIT, IOTYPE_ENTRANCE}
@onready var io_type: int = IOTYPE_PASS:
	set(val):
		io_type = val
		if val == IOTYPE_ENTRANCE:
			set_slot_enabled_left(0, false)
			set_slot_enabled_left(1, false)
		if val == IOTYPE_EXIT:
			set_slot_enabled_right(0, false)
			set_slot_enabled_right(1, false)
enum{IMODE_ALL = 0, IMODE_FIRST = 1, IMODE_ANY = 2}

func _ready():
	seq_pipe.fill_changed.connect(_on_seq_fill_changed)
	seq_pipe.token_ready.connect(_on_seq_token_ready)
	shared_pipe.token_taken.connect(_on_shared_token_taken)
	
func _on_seq_token_ready():
	pass
	
func _on_shared_token_taken(pipe: ScenarioPipe, empty: bool):
	if empty:
		set_slot_color_right(0, CLR_INACTIVE_SLOT)
	else:
		set_slot_color_right(0, CLR_ACTIVE_SHARED_SLOT)

func _on_seq_fill_changed(capacity_status: int):
	pass

func set_caption(text: String):
	title = text

func get_caption():
	return title

func set_description(text: String):
	$Description.text = text
		
func get_description():
	if $Description:
		return $Description.text
	else:
		return null

func manage_input(pipe: ScenarioPipe, port: int = SEQ_PORT):
	seq_pipe.connect_pipe(pipe)

	
func unmanage_input(node_name: String, port: int = SEQ_PORT):
	seq_pipe.disconnect_pipe(node_name)
	
func manage_output(node_name: String, port: int = SHARED_PORT):
	if port == SHARED_PORT:
		shared_pipe.register(node_name)
	
func unmanage_output(node_name: String, port: int = SHARED_PORT):
	if port == SHARED_PORT:
		shared_pipe.unregister(node_name)
		
func get_pipe(port: int):
	return shared_pipe

#func execute():
	##exec all executions mb JSONRPC???
	#
	##if final node just execute and then call a final
	#if io_type == IOTYPE_EXIT:
		#finish.emit()
	#
#func check():
	##TODO: check all checks and return total result
	#return true
	#
#func _process(delta):
	#if seq_pipe.has() and check():
		#var token = seq_pipe.pop()
		#if token:
			#execute()
			#shared_pipe.push(token)


func add_execution(exec):
	#editor
	pass
	
func remove_execution(exec):
	#from editor
	pass

func reset():
	seq_pipe.sink()
	shared_pipe.sink()

func poop_info():
	#print(name, "inputs: ", inputs.size(), " outputs: ", outputs.size())
	pass

func pop1():
	#if seq_pipe.has():
		#seq_pipe.pop()
	pass
	
func pop2():
	pass
	#if sync_pipe.has():
		#sync_pipe.pop()
	
func push1():
	var token : ScenarioToken = ScenarioToken.new()
	shared_pipe.push(token)
	
	
func push2():
	var token : ScenarioToken = ScenarioToken.new()
