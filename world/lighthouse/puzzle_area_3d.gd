extends Area3D

signal puzzle_piece_snapped

@export var required_puzzle_group: String = "PuzzlePiece"
@export var snap_duration: float = 0.4 

@onready var target_position_node: Marker3D = $TargetPosition

var current_piece_in_zone: XRToolsPickable = null
var is_solved: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D):
	if is_solved: return
	
	# Check of dit het juiste puzzelstuk is (bijv. via een Godot Group)
	if body.is_in_group(required_puzzle_group):
		current_piece_in_zone = body
		
		# Belangrijk: we gaan luisteren naar wanneer de speler DIT specifieke stuk loslaat
		if current_piece_in_zone.has_signal("dropped"):
			current_piece_in_zone.connect("dropped", _on_puzzle_piece_dropped)

func _on_body_exited(body: Node3D):
	if is_solved: return
	
	if body == current_piece_in_zone:
		# Als de speler het stuk weer weghaalt VOORDAT hij loslaat, stoppen we met luisteren
		if current_piece_in_zone.is_connected("dropped", _on_puzzle_piece_dropped):
			current_piece_in_zone.disconnect("dropped", _on_puzzle_piece_dropped)
		current_piece_in_zone = null

func _on_puzzle_piece_dropped():
	if not current_piece_in_zone or is_solved: return
	
	# Puzzelstuk is losgelaten ín de zone! Start het mooie snappen:
	snap_piece_to_place(current_piece_in_zone)

func snap_piece_to_place(piece: Node3D):
	is_solved = true
	
	if piece is RigidBody3D:
		piece.freeze = true
	
	if piece.has_method("set_pickable"):
		piece.enabled = false # Schakelt XRTools pickup uit
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(piece, "global_position", target_position_node.global_position, snap_duration)
	tween.tween_property(piece, "global_basis", target_position_node.global_basis, snap_duration)
	
	tween.chain().tween_callback(func():
		print("Puzzele is placed")
		puzzle_piece_snapped.emit()
	)
