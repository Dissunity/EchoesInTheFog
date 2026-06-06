extends AudioStreamPlayer3D


var rb_parent: RigidBody3D

var _duration = 0


func _ready() -> void:
	rb_parent = get_parent()
	_duration = stream.get_length()





func _process(_delta: float) -> void:
	if rb_parent.get_contact_count() > 0 and rb_parent.angular_velocity.length_squared() > 0.1:
			pitch_scale = sqrt(rb_parent.angular_velocity.length()) / 5
			if playing:
				return
			play(randf()*_duration)
	elif playing:
		stop()
		
	
