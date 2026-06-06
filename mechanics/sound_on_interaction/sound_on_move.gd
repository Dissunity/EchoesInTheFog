extends AudioStreamPlayer3D


var _rb_parent: RigidBody3D
var _duration: float
var _previous_position: Vector3
var _time_without_movement = 0
var _allowed_time_without_movement = 0.1

func _ready() -> void:
	_duration = stream.get_length()
	_rb_parent = get_parent()
	_previous_position = _rb_parent.global_position

func _process(delta: float) -> void:
	var new_position = _rb_parent.global_position
	var speed = (new_position-_previous_position).length()
	_previous_position = new_position
	if speed > 0.001 and not playing:
		play(randf()*_duration)
	elif speed <= 0.001:
		_time_without_movement += delta	
	if playing and _time_without_movement > _allowed_time_without_movement:
		stop()
		_time_without_movement = 0
	
	
