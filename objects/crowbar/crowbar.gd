extends Node3D

signal crowbar_taken


func _on_xr_tools_pickable_picked_up(_pickable: Variant) -> void:
	crowbar_taken.emit()
