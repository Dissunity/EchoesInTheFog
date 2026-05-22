extends Node
class_name TimeImpactedObject

@export var present_model: Node3D
@export var past_model: Node3D

var present: bool = true

func _ready():
	_toggle_collisions()

func _toggle_collisions():
	var present_collision_shapes = present_model.find_children("*", "CollisionShape3D")
	var past_collision_shapes = past_model.find_children("*", "CollisionShape3D")

	var disable = not present

	for present_shape in present_collision_shapes:
		present_shape.disabled = not disable
		#print("Present shape ", present_shape.name, " disabled status: ", present_shape.disabled)

	for past_shape in past_collision_shapes:
		past_shape.disabled = disable
		#print("Past shape ", past_shape.name, " disabled status: ", past_shape.disabled)


func toggle_time():
	present = not present
	present_model.visible = present
	past_model.visible = not present
	_toggle_collisions()
