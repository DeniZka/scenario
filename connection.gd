class_name Connection
extends Path2D

signal stop_called() #to OUT pin
signal exec_called() #to IN pin
signal remove_called(con: Connection)
const PICK_QDISTANCE = pow(10, 2)
const COLOR_NORMAL = Color(0.8, 0.8, 0.8)
const COLOR_SELECT = Color(1.0, 1.0, 1.0)

var active : bool = false #exec called / or stop called - innitial

# Called when the node enters the scene tree for the first time.
func _ready():
	curve = Curve2D.new()
	curve.add_point(Vector2.ZERO)
	curve.add_point(Vector2.ZERO)
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		remove_called.emit(self)

func call_stop():
	active = false
	stop_called.emit()

func remove_disconnect():
	remove_called.emit(self)

#from out pin
func call_exec():
	active = true
	exec_called.emit()

func is_active():
	return active
	
func set_point_pos(idx: int, pos: Vector2):
	curve.set_point_position(idx, pos)
	#calculate bezier points
	var v_btwn_pts : Vector2 = Vector2(
		abs(curve.get_point_position(1).x - curve.get_point_position(0).x) * 0.5, 
		0
	)
	curve.set_point_out(0, v_btwn_pts * -1)
	curve.set_point_in(1, v_btwn_pts * 1)
	
	$Lines.points = curve.get_baked_points()
	
func set_in_pos():
	pass
	
func set_out_pos():
	pass
	
func pick_select(pos: Vector2):
	var near_pt = curve.get_closest_point(pos)
	if near_pt.distance_squared_to(pos) <= PICK_QDISTANCE:
		$Lines.default_color = COLOR_SELECT
		return true
	return false

func deselect():
	$Lines.default_color = COLOR_NORMAL
