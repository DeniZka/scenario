class_name ScenarioToken
extends RefCounted

#there cuold place some lulz
var timers : Dictionary = {}
var vars : Dictionary = {}

#creator funciton
func new():
	pass
	
func add_timer(timer: Timer, name: String):
	if name:
		timers[name] = timer
		
func get_timer(name: String):
	if timers.has(name):
		return timers[name]
	else:
		return null
		
func add_var(v: int, name: String):
	if name:
		vars[name] = v
