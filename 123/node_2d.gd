extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Path2D/Line2D.points = $Path2D.curve.get_baked_points()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var pt2 : Vector2 = $Path2D.curve.get_point_position(2)
	var pt2i : Vector2= $Path2D.curve.get_point_in(2)
	var pt2o : Vector2= $Path2D.curve.get_point_out(2)
	$Path2D.curve.add_point(pt2, Vector2.ZERO, Vector2.ZERO, 3)
	$Path2D.curve.set_point_in(3, pt2i)
	$Path2D.curve.set_point_out(3, pt2o)
	
	$Path2D.curve.add_point(pt2, Vector2.ZERO, Vector2.ZERO, 2)
	$Path2D.curve.set_point_in(2, pt2i)
	$Path2D.curve.set_point_out(2, pt2o)
	
	$Path2D.curve.set_point_position(3, Vector2.INF)
	$Path2D/Line2D.points = $Path2D.curve.get_baked_points()
	pass # Replace with function body.
