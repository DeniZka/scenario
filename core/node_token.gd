class_name NodeToken
extends RefCounted

##interconnection info
#FIXME: what if token closed on function confirm true

enum{OFFER_STOPPED, OFFER_RUNNING, OFFER_PAUSED, OFFER_RESUMED}
signal offer_changed(token: NodeToken, offer_status: int)
#signal offer_activated() #customer executes and can accept
#signal offer_resumed() #custoomer can try accept (no execute)
#signal offer_closed() #customer resets

signal acception_changed(recipient_name: String, recip_status: bool) #for owner FIXME: not implemented
signal token_done()

var token_owner: String #node name
enum{TOKEN_UNKNOWN, TOKEN_ACCEPTED, TOKEN_REJECTED}
var customers: Dictionary = {} #acceptor: status

enum{MODE_CONCURENT, MODE_ANY} 
var mode: int = MODE_ANY
var token_active : int = OFFER_STOPPED
var disabled : bool = false #exclude node from network

func _init(owner: String):
	token_owner = owner

func set_mode(new_mode: int):
	mode = new_mode
	
func all_handled():
	var result = true
	for c in customers:
		if customers[c] == TOKEN_UNKNOWN:
			result = false
			break
	return result
	
func all_unhandled():
	var result = true
	for c in customers:
		if customers[c] != TOKEN_UNKNOWN:
			result = false
			break
	return result
	
func all_unaccepted():
	var result = true
	for c in customers:
		if customers[c] == TOKEN_ACCEPTED:
			result = false
			break
	return result
	
#owner functions
func place():
	token_active = OFFER_RUNNING
	offer_changed.emit(token_owner, OFFER_RUNNING)
	
func remove():
	token_active = OFFER_STOPPED
	for customer in customers:
		customers[customer] = TOKEN_UNKNOWN
	offer_changed.emit(token_owner, OFFER_STOPPED)
#для следящих выводов ХЗ покак как разрулить
func pause():
	token_active = OFFER_PAUSED
	offer_changed.emit(token_owner, OFFER_PAUSED)
	
func resume():
	token_active = OFFER_RUNNING  #there's not RESUMED on token_active
	offer_changed.emit(token_owner, OFFER_RESUMED)
	



#recipient functions
func register(customer_name: String):
	customers[customer_name] = TOKEN_UNKNOWN
	
func unregister(customer_name: String):
	customers.erase(customer_name)
	
func accept(customer_name: String):
	if token_active == OFFER_PAUSED or token_active == OFFER_STOPPED:
		return false
	if mode == MODE_ANY:
		if customers[customer_name] == TOKEN_UNKNOWN:
			acception_changed.emit(customer_name, true)
		else:
			return false
		customers[customer_name] = TOKEN_ACCEPTED
		if all_handled():
			token_done.emit()
		return true
	elif mode == MODE_CONCURENT:
		if not all_unaccepted():
			print("BUG??? CONCURETN TOKEN MUST BE FINISHED")
			token_done.emit()
			return false  #FIXME: bug? tokwn must be done!!
		acception_changed.emit(customer_name, true)
		token_done.emit()
		return true

#for first input mode
func reject(customer_name: String):
	if token_active == OFFER_PAUSED or token_active == OFFER_STOPPED:
		return false
	customers[customer_name] = TOKEN_REJECTED
	if mode == MODE_ANY:
		if all_handled():
			token_done.emit()
	return true
	#FIXME: RECJECT = ACCEPT for concurent mode?? - NO. disabled nodes reject too

func get_status(customer_name: String):
	return customers[customer_name]
	
func is_active():
	return token_active == OFFER_RUNNING
	
func is_disabled():
	return disabled
