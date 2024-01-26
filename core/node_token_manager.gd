class_name NodeTokenManager
extends RefCounted

signal execute_called()
signal pause_callded()
signal resume_called()

#manager for incoming tokens
#TODO: skip closed token when accept is true

var mode: int = MyGraphNode.IMODE_ALL
enum{STATUS_AWAIT, STATUS_EXEC, STATUS_CHECKING}
var tokens : Dictionary = {} #token:
var name: String
var disabled : bool = false #if disabled reject all but not execute


func _init(node_name: String):
	name = node_name
	
func set_mode(new_mode: int):
	mode = new_mode

func add_token(token: NodeToken):
	tokens[token] = STATUS_AWAIT
	token.offer_changed.connect(_on_offer_changed)
	token.register(name)
	
func remove_token(onwer_name: String):
	for token in tokens:
		if token.token_owner == onwer_name:
			token.unregister(name)
			token.offer_changed.disconnect(_on_offer_changed)
			tokens.erase(token)
			break
			
func all_paused():
	for token in tokens:
		if token.token_active != NodeToken.OFFER_PAUSED:
			return false
	return true
	
func all_stopped():
	return true
	
func all_active():
	for token in tokens:
		if not token.token_active != NodeToken.OFFER_RUNNING:
			return false
	return true
			
func all_exec():
	for token in tokens:
		if token.is_disabled():
			continue #skip disabled node
		if tokens[token] != STATUS_EXEC:
			return false
	return true
	
func any_exec():
	for token in tokens:
		if tokens[token] == STATUS_EXEC:
			return true
	return false

#if node turned to idle state it can recheck inputs
func check_offers():
	for token in tokens:
		if token.is_active():
			_on_offer_changed(token, NodeToken.OFFER_RUNNING)

func _on_offer_changed(from_token: NodeToken, offer_status: int):
	#TODO: tell node what to do
	if offer_status == NodeToken.OFFER_RUNNING:
		if disabled:
			from_token.reject(name)
			return
		if mode == MyGraphNode.IMODE_ALL:
			tokens[from_token] = STATUS_EXEC
			#check all nodes are running
			if all_exec():
				execute_called.emit()
		elif mode == MyGraphNode.IMODE_FIRST:
			if any_exec():
				from_token.reject(name)
			else:
				tokens[from_token] = STATUS_EXEC
				execute_called.emit()
		elif mode == MyGraphNode.IMODE_ANY:
			execute_called.emit()
	elif offer_status == NodeToken.OFFER_STOPPED:
		if mode == MyGraphNode.IMODE_ALL: #stop if any stopped
			
			pass
		elif mode == MyGraphNode.IMODE_ANY:
			pass #skip to next
	elif offer_status == NodeToken.OFFER_PAUSED:
		if all_paused():
			pause_callded.emit()
	elif offer_status == NodeToken.OFFER_RESUMED:
		resume_called.emit()

func accept(): #check passed
	if mode == MyGraphNode.IMODE_ANY:
		#accpet unaccepted
		for token in tokens:
			if token.is_active() and token.get_status(name) == NodeToken.TOKEN_UNKNOWN:
				token.accept(name)
	
	pass
