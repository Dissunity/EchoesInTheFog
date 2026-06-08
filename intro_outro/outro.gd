extends Node

@export var player: Player

func _process(_delta: float) -> void:
	if player.global_position.y < 0:
		get_tree().quit()
