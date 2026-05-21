extends Area3D

@export var label: Label3D
@export var target_position_node: Marker3D
@export var snap_duration: float = 0.4

signal puzzle_piece_snapped

var current_piece: Node3D = null
var is_solved: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Hellow"
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	label.text = "Area entered"
	print("Area entered")


func _on_area_exited(area: Area3D) -> void:
	label.text = "Area exited"
	print("Area exited")


func _on_body_entered(body: Node3D) -> void:
	if is_solved: return
	
	if body.is_in_group("PuzzlePiece"):
		label.text = "Puzzle Piece entered"
		print("Puzzle Piece entered")
		current_piece = body
		
		snap_piece_to_place(current_piece)

func snap_piece_to_place(piece: Node3D) -> void:
	is_solved = true
	label.text = "PuzzleSoved"
	
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

func _on_body_exited(body: Node3D) -> void:
	label.text = "Body exited"
	print("Body exited")
