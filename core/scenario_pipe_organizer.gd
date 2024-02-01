class_name ScenarioPipeOrganizer
extends ScenarioSharedPipe

enum{FILL_EMPTY, FILL_EXIST, FILL_ALMOST_FULL}
signal fill_changed(capacity_status: int)
var fill_status = FILL_EMPTY

var pipes: Array[ScenarioPipe]
enum{MODE_SYNCHRONIZE, MODE_OVERWRITE, MODE_AWAIT}
var mode: int = MODE_SYNCHRONIZE
var sync_limit = 0   #0 - synchronize all inputs, 1 - sequental mode, 2+ await for N tokens

func _init(owner_name: String, work_mode: int = MODE_SYNCHRONIZE):
	super(owner_name)
	mode = work_mode

func connect_pipe(pipe: ScenarioPipe):
	pipes.append(pipe)
	pipe.token_ready.connect(_on_token_ready)
	if pipe.has():
		_on_token_ready()
		
func pop(consumer_name: String = ""):
	if mode == MODE_AWAIT:
		for pipe in pipes:
			if pipe.has():
				pipe.pop(owner)
				return super.pop(consumer_name)
	else:
		return super.pop(consumer_name)
	
func disconnect_pipe(owner: String):
	for pipe in pipes:
		if pipe.owner == owner:
			pipe.token_ready.disconnect(_on_token_ready)
			pipes.erase(pipe)
			return

func _on_token_ready():
	if mode == MODE_SYNCHRONIZE:
		#FIXME: collect tokens unitil sync_limit!!!!
		var got_count = 0
		#check every pipe got token
		for pipe in pipes:
			if pipe.has(owner):
				got_count += 1
		if got_count == 0:
			if fill_status != FILL_EMPTY:
				fill_changed.emit(FILL_EMPTY)
				fill_status = FILL_EMPTY
		elif got_count <= pipes.size() - 1:
			if fill_status != FILL_ALMOST_FULL:
				fill_changed.emit(FILL_ALMOST_FULL)
				fill_status = FILL_ALMOST_FULL
		elif got_count == pipes.size():
			#do slef push(self:TOKEN)
			var token : ScenarioToken = null
			for pipe in pipes:
				token = pipe.pop(owner)
			push(token)
			fill_status = FILL_EMPTY
		else:
			if fill_status != FILL_EXIST:
				fill_changed.emit(FILL_EXIST) #FIXME: send only once
				fill_status = FILL_EXIST
	elif mode == MODE_OVERWRITE:
		#push every in one
		for pipe in pipes:
			if pipe.has():
				push(pipe.pop(owner))
	else:
		for pipe in pipes:
			if pipe.has():
				push(pipe.pick(owner))
