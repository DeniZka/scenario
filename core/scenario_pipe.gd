class_name ScenarioPipe
extends RefCounted

signal token_ready() #for consumer
signal token_taken(empty: bool) #for sender

var owner: String
var consumers : Dictionary = {}

func _init(owner_name: String):
	owner = owner_name
	
func push(token: ScenarioToken):
	pass
	
func pop(consumer_name: String = ""):
	pass
	
func got(consumer_name: String = ""):
	pass
		
func pick(consumer_name: String = ""):
	pass

func register(consumer_name: String):
	consumers[consumer_name] = []
	pass
	
func unregister(consumer_name: String):
	consumers.erase(consumer_name)
	pass
	
func sink():
	pass
	
