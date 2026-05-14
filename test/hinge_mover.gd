extends Node

@export var hinge: XRToolsInteractableHandleDriven


var pos

func _ready():
	pos = hinge.hinge_limit_max

func _process(delta: float) -> void:
	print(pos)
	if Input.is_action_pressed("ui_accept"):
		pos -= delta * 20
	else:
		pos += delta * 20
	
	pos = clamp(pos, hinge.hinge_limit_min, hinge.hinge_limit_max)
		
	hinge.move_hinge(deg_to_rad(pos))
