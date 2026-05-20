@tool
extends XRToolsMovementProvider
class_name MovementStairClimbing

## Movement provider order
@export var order : int = 7

# Controller node
var _controller : XRController3D

## Input action for movement direction
@export var input_action : String = "primary"
@export var input_forward : String = "ui_up"
@export var input_backward : String = "ui_down"
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"


@export var stair_detector: StairDetector


# Add support for is_xr_class on XRTools classes
func is_xr_class(xr_name:  String) -> bool:
	return xr_name == "XRToolsMovementDirect" or super(xr_name)


# Called when our node is added to our scene tree
func _enter_tree():
	_controller = XRHelpers.get_xr_controller(self)


# Called when our node is removed from our scene tree
func _exit_tree():
	_controller = null

func physics_pre_movement(_delta: float, _player_body: XRToolsPlayerBody):
	pass



var cooldown = 0

func physics_movement(delta: float, _player_body: XRToolsPlayerBody, _disabled: bool):
	var dz_input_action = XRToolsUserSettings.get_adjusted_vector2(_controller, input_action)
	var input_dir = Input.get_vector(input_left, input_right, input_backward, input_forward)
	cooldown -= delta
	if stair_detector.is_detecting_stairs() and _player_body.on_ground and (dz_input_action.y > 0.1 or input_dir.y > 0.1) and cooldown <= 0:
		cooldown = 0.4
		_player_body.position.y += 0.25
		_player_body.velocity.y = 1.5


# This method verifies the movement provider has a valid configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()

	# Check the controller node
	if not XRHelpers.get_xr_controller(self):
		warnings.append("This node must be within a branch of an XRController3D node")

	if stair_detector == null:
		warnings.append("Assign a stair detector")


	# Return warnings
	return warnings
