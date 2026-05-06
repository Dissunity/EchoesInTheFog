extends Node3D
@export var spawn_radius: float = 15.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	spawn_monster()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move the monster up and down	
	if self.visible:
		var move = sin(Time.get_ticks_msec() * 0.002 * 0.5) * 0.2
		self.position.y += move * delta

# The monster get's spawned in front of the player
func spawn_monster() -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	var player_pos = camera.global_position
	var forward = -camera.global_transform.basis.z
	forward.y = 0 
	forward = forward.normalized()

	var spawn_pos = Vector3(
			forward.x * spawn_radius, 
			player_pos.y,            
			forward.z * spawn_radius
		)
		
	self.global_position = spawn_pos
	self.visible = true
	
	var look_at_target = Vector3(player_pos.x, spawn_pos.y, player_pos.z)
	self.look_at(look_at_target, Vector3.UP)
