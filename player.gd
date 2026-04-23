extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003 

@onready var spring_arm = $SpringArm3D # Grabs the SpringArm for looking up/down

var is_desktop_mode = false # Used to toggle controls off for VR

func _ready() -> void:
    # Check if VR is active
    var xr_interface = XRServer.find_interface("OpenXR")
    if xr_interface and xr_interface.is_initialized():
        print("VR Mode detected. Desktop controls disabled.")
        set_physics_process(false)
        set_process_input(false)
        return
        
    # Desktop Mode setup
    print("Desktop Mode active.")
    is_desktop_mode = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Hides and locks the mouse

func _input(event: InputEvent) -> void:
    if not is_desktop_mode:
        return
        
    # Press ESC to free mouse so window can close
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        
    # Click the screen to lock the mouse again
    if event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    # Handle Mouse Turning
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        # Turn left/right
        rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
        # Look up/down
        spring_arm.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
        # Prevent the camera from doing a full 360-degree flip
        spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/2, PI/4)

func _physics_process(delta: float) -> void:
    if not is_desktop_mode:
        return

    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Handle jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    
    # transform.basis translates the inputs so player moves relative to where they are looking (strafing)
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()