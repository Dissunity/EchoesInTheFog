extends Area3D
class_name PuzzleArea

@export var target_position_node: Marker3D
@export var snap_duration: float = 0.4

signal puzzle_piece_snapped

var current_piece: Node3D = null
var is_solved: bool = false
var is_spinning: bool = false

func turn_spinning_on():
	is_spinning = true


func _process(delta: float) -> void:
	if not is_spinning:
		return
	rotate_x(delta)

func _on_area_entered(_area: Area3D) -> void:
	print("Area entered")


func _on_area_exited(_area: Area3D) -> void:
	print("Area exited")


func _on_body_entered(body: Node3D) -> void:
	if is_solved: return
	
	if body.is_in_group("PuzzlePiece"):
		print("Puzzle Piece entered")
		current_piece = body
		
		snap_piece_to_place(current_piece)

func snap_piece_to_place(piece: Node3D) -> void:
	is_solved = true
	
	piece.enabled = false
	
	if piece is RigidBody3D:
		piece.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		piece.freeze = true
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(piece, "global_position", target_position_node.global_position, snap_duration)
	tween.tween_property(piece, "global_basis", target_position_node.global_basis, snap_duration)
	
	tween.chain().tween_callback(func():
		puzzle_piece_snapped.emit()
	)

func _on_body_exited(_body: Node3D) -> void:
	print("Body exited")
