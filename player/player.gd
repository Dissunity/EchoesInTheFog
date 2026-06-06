extends XROrigin3D
class_name Player

signal reached_target_height(is_high_enough: bool)

@export var target_height: float = 58.2 # Fresnel room

var was_above_height: bool = false

@onready var xr_camera: XRCamera3D = $XRCamera3D
@onready var player_body: XRToolsPlayerBody = $PlayerBody


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func enable_movement():
	$LeftHand/FunctionPickup.enabled = true
	$LeftHand/FunctionTeleport.enabled = true
	$LeftHand/MovementDirect.enabled = true
	$LeftHand/MovementDesktopDirect.enabled = true
	$LeftHand/MovementStairClimbing.enabled = true
	$RightHand/FunctionPickup.enabled = true
	$RightHand/MovementTurn.enabled = true
	$RightHand/XRToolsDesktopMovementTurn.enabled = true
	$RightHand/MovementDesktopCrouch.enabled = true
	$RightHand/MovementCrouch.enabled = true

func disable_movement():
	$LeftHand/FunctionPickup.enabled = false
	$LeftHand/FunctionTeleport.enabled = false
	$LeftHand/MovementDirect.enabled = false
	$LeftHand/MovementDesktopDirect.enabled = false
	$LeftHand/MovementStairClimbing.enabled = false
	$RightHand/FunctionPickup.enabled = false
	$RightHand/MovementTurn.enabled = false
	$RightHand/XRToolsDesktopMovementTurn.enabled = false
	$RightHand/MovementDesktopCrouch.enabled = false
	$RightHand/MovementCrouch.enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if not xr_camera: 
		print("XRCamera is missing in XROrigin")
		return
	
	var current_world_height = xr_camera.global_position.y
		
	var is_above = current_world_height >= target_height
	
	if is_above != was_above_height:
		print("Current height player:", current_world_height)
		was_above_height = is_above
		reached_target_height.emit(is_above)
