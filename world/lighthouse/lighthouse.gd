extends Node3D

signal foghorn_lever_pulled
signal mechanical_piece_snapped

@export var foghorn_enabled: bool = true
@export var foghorn_cooldown: float = 30


var _foghorn_cooldown_left: float = 0


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


func _on_puzzle_piece_snapped() -> void:
	mechanical_piece_snapped.emit()
