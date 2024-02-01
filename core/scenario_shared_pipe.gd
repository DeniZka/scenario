class_name ScenarioSharedPipe
extends ScenarioPipe

var token: ScenarioToken = null

func push(in_token: ScenarioToken):
	#do not push if no consumers
	#if consumers.size() > 0:
	token = in_token
	token_ready.emit()

func pop(consumer_name: String = ""):
	var result = token
	token = null
	token_taken.emit(self, true)
	return result

func has(consumer_name: String = ""):
	if token:
		return true
	else:
		return false
		
func pick(consumer_name: String = ""):
	if token:
		return token
	else:
		return null
		
func sink():
	token = null
