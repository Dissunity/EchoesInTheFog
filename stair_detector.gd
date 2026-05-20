extends RayCast3D
class_name StairDetector

func is_detecting_stairs() -> bool:
	var collider = get_collider() as Node3D
	if not collider:
		return false
	var collider_parent = collider.get_parent()
	if not collider_parent:
		return false
		
	if collider_parent.name == "Stairs_001" or collider_parent.name == "Floor Viewing level _001":
		return true
	return false
