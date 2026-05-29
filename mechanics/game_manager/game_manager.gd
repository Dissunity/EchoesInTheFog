extends Node3D

signal time_travelled
signal crowbar_taken
signal lockbox_opened
signal puzzle_snapped
signal player_went_upstairs

@export var time_travel_light: OmniLight3D

@export var player: XROrigin3D
@export var puzzleHolder: Area3D
@export var monster: Node3D
@export var gear_audio: AudioStreamPlayer3D
@export var monster_audio: AudioStreamPlayer3D
@export var lighthouse_light: SpotLight3D

# To see whether the player is in the fresnel room
# And the puzzle piece is on the snap area
var player_is_high_enough: bool = false
var puzzle_is_snapped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().audio_listener_enable_3d = true
	
	if not player or not puzzleHolder or not monster or not gear_audio or not monster_audio or not lighthouse_light:
			push_error("GameManager is missing one or more nodes in the Inspector!")
			return
	
	monster_audio.volume_db = -80.0
	gear_audio.volume_db = -80.0
	lighthouse_light.light_energy = 0.0
		
	# These objects emit a signal indicating when the conditions are met
	player.reached_target_height.connect(_on_player_height_changed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _check_conditions():
	if puzzle_is_snapped:
		if player_is_high_enough:
			await get_tree().create_timer(4).timeout
			if monster_audio and not monster_audio.playing:
				monster_audio.play() # Start playing the silent track
				var audio_tween = create_tween()
				# Fade from -80dB to -4dB over 2.5 seconds
				audio_tween.tween_property(monster_audio, "volume_db", -4.0, 2.5)
			monster.spawn()
			_on_game_end()

func _on_crowbar_taken():
	crowbar_taken.emit()

func _on_lockbow_opened():
	lockbox_opened.emit()

func _on_time_travelled():
	time_travelled.emit()

func _on_player_height_changed(is_high_enough: bool):
	player_is_high_enough = is_high_enough
	player_went_upstairs.emit()
	print("GameManager player status changes to: ", is_high_enough)
	_check_conditions()
	
func _on_puzzle_piece_snapped() -> void:
	puzzle_is_snapped = true
	puzzle_snapped.emit()
	#print("GameManager puzzleholder status changes to: ", puzzle_is_snapped)
	if gear_audio and not gear_audio.playing:
		gear_audio.play() # Start playing the silent track
		var audio_tween = create_tween()
		# Fade from -80dB to -4dB over 2.5 seconds
		audio_tween.tween_property(gear_audio, "volume_db", -4.0, 2.5)
	
	if lighthouse_light:
		var light_tween = create_tween()
		# Fades the light energy from 0.0 to 5.0 over 2.5 seconds
		light_tween.tween_property(lighthouse_light, "light_energy", 5.0, 2.5)
	
	_check_conditions()
	
func _on_game_end() -> void:
	await get_tree().create_timer(3.0).timeout
	
	var tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(time_travel_light, "light_energy", 100, 3)
	for i in range(20):
		tween.tween_property(time_travel_light, "light_energy", 100, 0.2)
		tween.tween_property(time_travel_light, "light_energy", 500, 0.2)

	tween.tween_property(time_travel_light, "light_energy", 0, 2).set_ease(Tween.EASE_OUT)

	
	await get_tree().create_timer(1.0).timeout

	get_tree().quit()
