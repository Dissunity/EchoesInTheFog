extends XROrigin3D
 
@onready var camera = $XRCamera3D
@onready var left_controller = $LeftHand
@onready var right_controller = $RightHand
 
var speed = 3.0   # movement speed (meters per second)
 
func _physics_process(delta):
	# Get joystick input (Vector2)
	var input_vec = left_controller.get_vector2("primary")
 
	# Get direction based on where the headset is facing
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
 
	# Prevent vertical movement
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
 
	# Combine joystick input with directions
	var direction = forward * input_vec.y + right * input_vec.x
 
	# Move the player (XROrigin3D)
	global_position += direction * speed * delta
 
	var turn_input = right_controller.get_vector2("primary").x
	if abs(turn_input)>0.2:
		rotate_y(-turn_input * 2.0 * delta)
		
	# implements flying
	var vertical = 0.0
	
	if 	right_controller.is_button_pressed("ax_touch"):
		print("go up")
		vertical += 1.0
		
	if right_controller.is_button_pressed("by_touch") or right_controller.is_button_pressed("down_button"):
		print("go down")
		vertical -= 1.0	
	
	global_position += Vector3.UP * vertical * speed * delta	
