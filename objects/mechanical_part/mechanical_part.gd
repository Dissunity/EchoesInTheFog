extends Node3D
class_name MechanicalPart

@onready var pickable: XRToolsPickable = $RigidBody

var _spinning = false

func start_spinning():
	_spinning = true

func _process(delta: float) -> void:
	if _spinning:
		pickable.rotate_x(delta)
