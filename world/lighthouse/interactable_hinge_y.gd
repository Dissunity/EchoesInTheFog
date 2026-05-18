@tool
extends XRToolsInteractableHinge

## XR Tools Interactable Hinge script
##
## The interactable hinge is a hinge transform node controlled by the
## player through one or more [XRToolsInteractableHandle] instances.
##
## The hinge rotates itelf around its local X axis, and so should be
## placed as a child of a node to translate and rotate as appropriate.
##
## The interactable hinge is not a [RigidBody3D], and as such will not react
## to any collisions.

# Add support for is_xr_class on XRTools classes
func is_xr_class(xr_name:  String) -> bool:
	return xr_name == "XRToolsInteractableHinge" or super(xr_name)

func _ready():
	# super() regelt de signaalverbindingen al in de basisklasse!
	super()

	# Set the initial position (Y-as rotatie in de transform)
	transform = Transform3D(
		Basis.from_euler(Vector3(0, _hinge_position_rad, 0)),
		Vector3.ZERO
	)

func _process(_delta: float) -> void:
	if grabbed_handles.is_empty():
		return

	var offset_sum := 0.0
	for item in grabbed_handles:
		var handle := item as XRToolsInteractableHandle
		#var to_handle: Vector3 = handle.global_transform.origin * global_transform
		#var to_handle_origin: Vector3 = handle.handle_origin.global_transform.origin * global_transform
		
		var to_handle = to_local(handle.global_transform.origin)
		var to_handle_origin = to_local(handle.handle_origin.global_transform.origin)
				
		
		# Projecteer op het XZ-vlak (we negeren Y voor een Y-hinge)
		to_handle.y = 0.0
		to_handle_origin.y = 0.0
		
		# Gebruik Vector3.UP als as voor de hoekberekening
		offset_sum += to_handle_origin.signed_angle_to(to_handle, Vector3.UP)

	var offset := offset_sum / grabbed_handles.size()
	move_hinge(_hinge_position_rad + offset)

func _do_move_hinge(pos: float) -> float:
	if _hinge_steps_rad:
		pos = round(pos / _hinge_steps_rad) * _hinge_steps_rad

	pos = clamp(pos, _hinge_limit_min_rad, _hinge_limit_max_rad)

	if pos != _hinge_position_rad:
		transform.basis = Basis.from_euler(Vector3(0.0, pos, 0.0))

	return pos
