extends Node3D


func _ready() -> void:
	await get_tree().create_timer(5).timeout
	var staging: XRToolsStaging = get_tree().root.get_node("Staging")
	staging.load_scene("res://world/world.tscn")
