extends Node
## Hinge Mover
## This script is only used as a test script to move the hinge without the need of XR

## Hinger which will be moved with ENTER button hold
@export var hinge: XRToolsInteractableHandleDriven

var pos

func _ready():
	pos = hinge.hinge_limit_max

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		pos -= delta * 20
	else:
		pos += delta * 20
	pos = clamp(pos, hinge.hinge_limit_min, hinge.hinge_limit_max)
	hinge.move_hinge(deg_to_rad(pos))
