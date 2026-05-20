extends Node3D

@export var player: XROrigin3D
@export var puzzleHolder: Area3D
@export var monster: Node3D
@export var vr_fade: Node3D 

# To see whether the player is in the fresnel room
# And the puzzle piece is on the snap area
var player_is_high_enough: bool = false
var puzzle_is_snapped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not player or not puzzleHolder or not monster:
			push_error("GameManager is missing one or more nodes in the Inspector!")
			return
			
	# These objects emit a signal indicating when the conditions are met
	player.reached_target_height.connect(_on_player_height_changed)
	puzzleHolder.puzzle_piece_snapped.connect(_on_puzzle_piece_snapped)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _check_conditions():
	if puzzle_is_snapped:
		if player_is_high_enough:
			print("Monster should appear")
			monster.spawn()
			_on_game_end()

func _on_player_height_changed(is_high_enough: bool):
	player_is_high_enough = is_high_enough
	print("GameManager player status changes to: ", is_high_enough)
	_check_conditions()
	
func _on_puzzle_piece_snapped() -> void:
	puzzle_is_snapped = true
	print("GameManager puzzleholder status changes to: ", puzzle_is_snapped)
	_check_conditions()
	
func _on_game_end() -> void:
	await get_tree().create_timer(3.0).timeout
	if vr_fade and vr_fade.has_method("fade_to_black"):
		vr_fade.fade_to_black(2.0) 
		
		await get_tree().create_timer(2.0).timeout
	else:

		var fade_tween = create_tween()
		fade_tween.tween_property(vr_fade, "material_override:albedo_color:a", 1.0, 2.0)
		await fade_tween.finished
		
	await get_tree().create_timer(1.0).timeout
	
	print("Game ended. VR Application closing...")
	get_tree().quit()
