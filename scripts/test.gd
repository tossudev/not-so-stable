extends Node2D


var dropping: bool = false
var drop_node: Object
var final_piece: Object

var current_drop: Object
var can_drop: bool = false

var drop_pos: Vector2
var middle_pos: Vector2

var weight_left: float = 0.0
var weight_right: float = 0.0

var overload_amount: float = 30.0


func _ready():
	final_piece = $FinalPiece
	drop_node = $Drop


func _process(_delta):
	_update_dropping()
	_update_tower()


func _update_dropping() -> void:
	if !dropping or current_drop == null:
		return
	
	var mouse_pos = get_global_mouse_position()
	current_drop.position = mouse_pos
	
	if Input.is_action_just_pressed("mouse1"):
		_drop()


func _update_tower() -> void:
	$Tower.rotation_degrees = lerp($Tower.rotation_degrees, -weight_left - weight_right, 0.02)
	
	print(weight_left - weight_right)
	var dead: bool = weight_left - weight_right > overload_amount


func _drop() -> void:
	dropping = false
	
	var new_piece = final_piece.duplicate()
	$Tower/Platform1.add_child(new_piece)
	drop_pos = current_drop.global_position
	
	var positions: Array = []
	for pos in $Tower/Platform1/Positions.get_children():
		positions.append(pos.global_position)
	
	middle_pos = $Tower/Platform1.global_position
	
	positions.sort_custom(sort_ascending)
	new_piece.global_position = positions[0]
	
	weight_left += positions[0].distance_to(middle_pos) / 10
	
	current_drop.queue_free()


func sort_ascending(a, b):
	if drop_pos.distance_to(a) < drop_pos.distance_to(b):
		return true
	return false



func _on_new_drop_button_pressed():
	dropping = true
	current_drop = drop_node.duplicate()
	add_child(current_drop)


func _on_drop_area_mouse_entered():
	if dropping:
		can_drop = true


func _on_drop_area_mouse_exited():
	can_drop = false
