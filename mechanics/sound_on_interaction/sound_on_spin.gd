extends AudioStreamPlayer3D


var _rb_parent: RigidBody3D
var _last_position: Vector3
var _duration: float

func _ready() -> void:
	_rb_parent = get_parent()
	_last_position = _rb_parent.position
	_duration = stream.get_length()

func _process(_delta: float) -> void:
	var new_position = _rb_parent.position
	var speed = (new_position-_last_position).length()
	_last_position = new_position
	volume_linear = clamp(speed * 20, 0, 1)
	pitch_scale = clamp(speed * 20, 0.9, 1.1)
	if speed > 0.001 and !playing:
		play(randf()*_duration)
	elif speed <= 0.001 and playing:
		stop()
