extends AudioStreamPlayer3D


var _rb_parent: RigidBody3D

func _ready() -> void:
	_rb_parent = get_parent()


func _process(_delta: float) -> void:
	var speed = _rb_parent.linear_velocity.length()
	volume_linear = clamp(speed/20, 0, 1)
	if speed > 6 and !playing:
		pitch_scale = randfn(speed/6, 0.1)
		play()
