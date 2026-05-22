extends Node3D

# The speed of the rotation. 
# You can change this number right in the Godot Inspector!
@export var rotation_speed: float = 0.7

func _process(delta: float) -> void:
	# rotate_y spins the node around Godot's vertical axis (Up/Down)
	rotate_y(rotation_speed * delta)
