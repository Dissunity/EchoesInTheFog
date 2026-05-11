extends Node


@export var time_travel_light: TimeTravelLight
@export var time_impacted_objects: Array[TimeImpactedObject]

@export var test: bool = false

func time_travel():
	time_travel_light.time_travel()
	await get_tree().create_timer(1.5).timeout
	for obj in time_impacted_objects:
		obj.toggle_time()

func _process(_delta: float) -> void:
	if test:
		if Input.is_action_just_pressed("ui_accept"):
			time_travel()
