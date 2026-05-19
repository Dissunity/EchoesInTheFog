extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003 

@onready var spring_arm = $SpringArm3D
@onready var desktop_camera = $SpringArm3D/DesktopCamera
@onready var xr_origin = $XROrigin3D
@onready var xr_camera = $XROrigin3D/XRCamera3D
@onready var left_controller = $XROrigin3D/LeftHand
@onready var neck_position_node = $XROrigin3D/XRCamera3D/Neck

var is_desktop_mode = false 

func _ready() -> void:
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("VR Mode detected. Enabling XR Camera.")
		is_desktop_mode = false
		desktop_camera.current = false 
	else:
		print("Desktop Mode active.")
		is_desktop_mode = true
		desktop_camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 

func _input(event: InputEvent) -> void:
	if not is_desktop_mode:
		return
		
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		spring_arm.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/2, PI/4)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Vector3.ZERO

	# --- DESKTOP CONTROLS (WASD) ---
	if is_desktop_mode:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# --- VR CONTROLS (Joystick) ---
	else:
		var input_vec = left_controller.get_vector2("primary")
		var forward = -xr_camera.global_transform.basis.z
		var right = xr_camera.global_transform.basis.x
		
		# Prevent flying when looking up/down
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		
		# Apply joystick input to direction
		direction = forward * input_vec.y + right * input_vec.x
		
		# Added from the documentation tutorial
		var is_colliding = _process_on_physical_movement(delta)
		if !is_colliding:
			_process_rotation_on_input(delta)
			_process_movement_on_input(delta)
	# --- APPLY FINAL MOVEMENT ---
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _process_on_physical_movement(delta) -> bool:
	# Remember our current velocity, we'll apply that later
	var current_velocity = velocity

	# Start by rotating the player to face the same way our real player is
	var camera_basis: Basis = xr_origin.transform.basis * XRCamera3D.transform.basis
	var forward: Vector2 = Vector2(camera_basis.z.x, camera_basis.z.z)
	var angle: float = forward.angle_to(Vector2(0.0, 1.0))
	
	# Rotate our character body
	transform.basis = transform.basis.rotated(Vector3.UP, angle)
	
	# Reverse this rotation our origin node
	xr_origin.transform = Transform3D().rotated(Vector3.UP, -angle) * xr_origin.transform

	# Now apply movement, first move our player body to the right location
	var org_player_body: Vector3 = global_transform.origin
	var player_body_location: Vector3 = xr_origin.transform * xr_camera.transform * neck_position_node.transform.origin
	player_body_location.y = 0.0
	player_body_location = global_transform * player_body_location

	velocity = (player_body_location - org_player_body) / delta
	move_and_slide()

	# Now move our XROrigin back
	var delta_movement = global_transform.origin - org_player_body
	xr_origin.global_transform.origin -= delta_movement
	
	# Return our value
	velocity = current_velocity
	
	if (player_body_location - global_transform.origin).length() > 0.01:
		# We'll talk more about what we'll do here later on
		return true
	else:
		return false

func _get_rotational_input() -> float:
	# Implement this function to return rotation in radians per second.
	return 0.0

func _process_rotation_on_input(delta):
	rotation.y += _get_rotational_input() * delta

func _get_movement_input() -> Vector2:
	# Implement this to return requested directional movement in meters per second.
	return Vector2()

func _process_movement_on_input(delta):
	var movement_input = _get_movement_input()
	var direction = global_transform.basis * Vector3(movement_input.x, 0, movement_input.y)
	if direction:
		velocity.x = direction.x
		velocity.z = direction.z
	else:
		velocity.x = move_toward(velocity.x, 0, delta)
		velocity.z = move_toward(velocity.z, 0, delta)
		
	move_and_slide()
