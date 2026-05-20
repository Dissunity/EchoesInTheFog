extends Node3D

@export var player: XROrigin3D
#@export var puzzleHolder: XRToolsSnapZone
@export var monster: Node3D

# To see whether the player is in the fresnel room
# And the puzzle piece is on the snap area
var player_is_high_enough: bool = false
var puzzle_is_snapped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if not player or not puzzleHolder or not monster:
			#push_error("GameManager is missing one or more nodes in the Inspector!")
			#return
	
	player.reached_target_height.connect(_on_player_height_changed)
	#puzzleHolder.has_picked_up.connect(_on_object_snapped)
	#puzzleHolder.has_dropped.connect(_on_object_dropped)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_check_conditions()
	
func _check_conditions():
	if puzzle_is_snapped:
		if player_is_high_enough:
			print("Add monster function here")
			pass
		#if monster.has_method("appear"):
			#monster.appear

func _on_player_height_changed(is_high_enough: bool):
	player_is_high_enough = is_high_enough
	print("GameManager player status changes to: ", is_high_enough)
	_check_conditions()
	
func _on_object_snapped(what: Node3D):
	puzzle_is_snapped= true
	print("Object is placed in snapzone: ", what.name)
	_check_conditions()

func _on_object_dropped():
	puzzle_is_snapped = false
	print("Object is removed from snapzone")
