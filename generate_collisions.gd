@tool
extends EditorScript

func _run():
	var root = EditorInterface.get_edited_scene_root()
	
	if root == null:
		print("No scene")
		return
		
	process_node(root)
	print("Collision generation finished.")


func process_node(node):
	for child in node.get_children():
		
		if child.name == "Ocean":
			continue
		
		if child is MeshInstance3D and child.mesh:
			make_static_body(child)
		
		process_node(child)


func make_static_body(mesh_instance: MeshInstance3D):
	var parent = mesh_instance.get_parent()
	
	# Create StaticBody3D
	var static_body = StaticBody3D.new()
	static_body.name = mesh_instance.name + "_Body"
	parent.add_child(static_body)
	static_body.owner = mesh_instance.owner
	
	# Copy transform
	static_body.transform = mesh_instance.transform
	
	# Move mesh under StaticBody3D
	parent.remove_child(mesh_instance)
	static_body.add_child(mesh_instance)
	mesh_instance.owner = static_body.owner
	
	# Reset local transform so it doesn't double-transform
	mesh_instance.transform = Transform3D.IDENTITY
	
	# Create CollisionShape3D
	var collision = CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	
	# Generate trimesh collision
	collision.shape = mesh_instance.mesh.create_trimesh_shape()
	
	static_body.add_child(collision)
	collision.owner = static_body.owner
