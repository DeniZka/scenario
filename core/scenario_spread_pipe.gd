class_name ScenarioSpreadPipe
extends ScenarioPipe



func push(token: ScenarioToken):
	#split token
	for consumer in consumers:
		consumers[consumer].append(token)
	token_ready.emit()

func pop(consumer_name: String = ""):
	var result = consumers[consumer_name]
	consumers[consumer_name] = null
	for consumer in consumers:
		if not consumers[consumer]:
			token_taken.emit(false)
			return result
	token_taken.emit(true)
	return result
	
func has(consumer_name: String = ""):
	if consumers[consumer_name]:
		return true
	else:
		return false
		
func pick(consumer_name: String = ""):
	return consumers[consumer_name]
	
func sink():
	for consumer in consumers:
		consumers[consumer] = null


