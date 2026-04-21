extends XROrigin3D
 
@onready var camera = $XRCamera3D
@onready var left_controller = $LeftHand
@onready var right_controller = $RightHand
 
var speed = 3.0   # movement speed (meters per second)
 
func _physics_process(delta):
	# 1. Get joystick input (Vector2)
	var input_vec = left_controller.get_vector2("primary")
 
	# 2. Ignore tiny input (deadzone)
	if input_vec.length() < 0.1:
		return
 
	# 3. Get direction based on where the headset is facing
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
 
	# 4. Prevent vertical movement
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
 
	# 5. Combine joystick input with directions
	var direction = forward * input_vec.y + right * input_vec.x
 
	# 6. Move the player (XROrigin3D)
	global_position += direction * speed * delta

	var turn_input = right_controller.get_vector2("primary").x
	if abs(turn_input)>0.2:
		rotate_y(-turn_input * 2.0 * delta)
