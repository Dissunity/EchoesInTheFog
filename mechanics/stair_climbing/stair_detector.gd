extends Area3D
class_name StairDetector

@export var bodies_to_react_to: Array[PhysicsBody3D]


func is_detecting_stairs() -> bool:
	for body in bodies_to_react_to:
		if overlaps_body(body):
			return true
	return false
	#var collider = get_collider() as Node3D
	#pass
	#
	#if not collider:
		#return false
	#var collider_parent = collider.get_parent()
	#if not collider_parent:
		#return false
		#
	#if collider_parent.name == "Stairs_001" or collider_parent.name == "Floor Viewing level _001":
		#return true
	#return false
