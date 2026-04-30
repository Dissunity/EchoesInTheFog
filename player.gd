extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003 

@onready var spring_arm = $SpringArm3D
@onready var desktop_camera = $SpringArm3D/DesktopCamera
@onready var xr_origin = $XROrigin3D
@onready var xr_camera = $XROrigin3D/XRCamera3D
@onready var left_controller = $XROrigin3D/LeftHand

var is_desktop_mode = false 

func _ready() -> void:
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("VR Mode detected. Enabling XR Camera.")
		is_desktop_mode = false
		desktop_camera.current = false 
		xr_camera.current = true
		spring_arm.spring_length = 0.0
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
		
		

	# --- APPLY FINAL MOVEMENT ---
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
