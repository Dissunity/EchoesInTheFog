extends Node3D



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		$AnimationPlayer.play("ArmatureAction")
		await get_tree().create_timer(3).timeout
		$AnimationPlayer.play_backwards("ArmatureAction")
