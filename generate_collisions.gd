@tool
extends EditorScript
func _run():
	var root = EditorInterface.get_edited_scene_root()
	
	if root == null:
		print("No scene")
		return
		
	process_node(root)	
	print("collision generation finished.")
	
func process_node(node):
	for child in node.get_children():
		
		if child.name == "Ocean":
			continue
		
		if child is MeshInstance3D and child.mesh:
			if child.get_child_count() == 0:
				child.create_trimesh_collision()
	
		process_node(child)				
