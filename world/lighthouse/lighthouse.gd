extends Node3D

signal foghorn_lever_pulled
signal mechanical_piece_snapped

@onready var rotating_spotlight = $TopRoom/RotatingSpotlight
@onready var upper_gear: UpperGear = $MiddleRoom/Mechanism/Cabinet/Gear
@onready var turn_lever: XRToolsInteractableHinge = $MiddleRoom/Mechanism/Cabinet/TurnLever/LeverSmooth/LeverOrigin/InteractableLever
@onready var mechanism_audio: AudioStreamPlayer3D = $MiddleRoom/Mechanism/MechanismAudio
var puzzle_piece: MechanicalPart

@export var foghorn_enabled: bool = true
@export var foghorn_cooldown: float = 30
var _foghorn_cooldown_left: float = 0
var _puzzle_snapped: bool = false
var _mechanism_on = false

var _turn_lever_last_position: float
var _amount_spun = 0

func _ready() -> void:
	_turn_lever_last_position = turn_lever.hinge_position
	puzzle_piece = get_tree().get_nodes_in_group("PuzzlePiece")[0].get_parent()

func _turn_mechanism_on():
	if _mechanism_on:
		return
	upper_gear.turn_spinning_on()
	rotating_spotlight.visible = true
	mechanism_audio.play()
	foghorn_enabled = true
	puzzle_piece.start_spinning()
	_mechanism_on = true

func _on_foghorn_hinge_moved(angle: Variant) -> void:
	if not foghorn_enabled:
		return
	if _foghorn_cooldown_left > 0:
		return
	if abs(angle) < 30:
		return
	_foghorn_cooldown_left = foghorn_cooldown
	foghorn_lever_pulled.emit()

func _process(delta: float) -> void:
	_foghorn_cooldown_left -= delta
	var new_turn_lever_position = turn_lever.hinge_position
	if _puzzle_snapped and new_turn_lever_position != _turn_lever_last_position:
		_amount_spun += delta
	_turn_lever_last_position = new_turn_lever_position
	if _amount_spun > 3:
		_turn_mechanism_on()


func _on_puzzle_piece_snapped() -> void:
	_puzzle_snapped = true
	mechanical_piece_snapped.emit()
