extends Node3D
class_name UpperGear


var _is_spinning = false

func turn_spinning_on():
	_is_spinning = true

func _process(delta: float) -> void:
	if _is_spinning:
		rotate_y(delta)
