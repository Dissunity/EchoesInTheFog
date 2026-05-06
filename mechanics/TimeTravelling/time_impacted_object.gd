extends Node
class_name TimeImpactedObject

@export var present_model: Node3D
@export var past_model: Node3D

var present: bool = true

func toggle_time():
	present = not present
	present_model.visible = present
	past_model.visible = not present
