extends Area3D
class_name StairDetector

@export var group_to_detect: String = "Stairs"


func is_detecting_stairs() -> bool:
	var bodies: Array[Node3D] = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group(group_to_detect):
			return true
	return false
