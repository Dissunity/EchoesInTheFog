extends XROrigin3D

signal reached_target_height(is_high_enough: bool)

@export var target_height: float = 58.2 # Fresnel room

var was_above_height: bool = false

@onready var xr_camera: XRCamera3D = $XRCamera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not xr_camera: 
		print("XRCamera is missing in XROrigin")
		return
	
	var current_world_height = xr_camera.global_position.y
		
	var is_above = current_world_height >= target_height
	
	if is_above != was_above_height:
		print("Current height player:", current_world_height)
		was_above_height = is_above
		reached_target_height.emit(is_above)
