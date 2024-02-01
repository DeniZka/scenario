class_name TimerGraphNode
extends MyGraphNode

#const MAX_INT : int = 9223372036854775807
const MAX_FLOAT : float = 1e10


@onready var tname = $LEName
@onready var timer : Timer = $Timer
@onready var hour = $HBTimer/SBHour
@onready var min = $HBTimer/SBMin
@onready var sec = $HBTimer/SBSec
@onready var jhour = $HBTimer2/SBHour
@onready var jmin = $HBTimer2/SBMin
@onready var jsec = $HBTimer2/SBSec
@onready var async : CheckBox = $CheckBox


var token : ScenarioToken = null

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

func _on_seq_token_ready():
	token = seq_pipe.pop()
	if token:
		token.add_timer(timer, tname.text)
		timer.stop()
		#Jitter
		var time = hour.value * 3600 + min.value * 60 + sec.value
		var jtime = jhour.value * 3600 + jmin.value * 60 + jsec.value
		if time == 0:
			timer.start(MAX_FLOAT)
		else:
			timer.start(time + randi_range(-jtime, jtime))
		if async.button_pressed:
			set_slot_color_right(0, CLR_INPUT_ANY)
			shared_pipe.push(token)
			token = null
		else:
			set_slot_color_left(0, CLR_INPUT_ANY)
			
#func _process(delta):
	#if token:
		#print(timer.wait_time - timer.time_left)
	#pass

func _on_timer_timeout():
	if not async.button_pressed and token:
		set_slot_color_right(0, CLR_INPUT_ANY)
		set_slot_color_left(0, Color(1,1,1))
		shared_pipe.push(token)
		token = null
		
