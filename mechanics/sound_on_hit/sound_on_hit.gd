extends AudioStreamPlayer3D


var rb_parent: RigidBody3D


func _ready() -> void:
	rb_parent = get_parent()

func _process(delta: float) -> void:
	cooldown_left -= delta


var sound_cooldown = 0.2
var cooldown_left = 0

func _on_collission(_body: Node) -> void:
	if rb_parent.linear_velocity.length() > 0.01:
		if cooldown_left > 0:
			return
		cooldown_left = sound_cooldown
		volume_linear = rb_parent.linear_velocity.length_squared()/6
		pitch_scale = randfn(1, 0.2)
		play()
