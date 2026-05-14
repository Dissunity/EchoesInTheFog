extends Node


@export var time_travel_light: TimeTravelLight
@export var time_impacted_objects: Array[TimeImpactedObject]
@export var hinge: XRToolsInteractableHandleDriven
@export var test: bool = false

var cooldown = 0


func time_travel():
	cooldown = 10
	hinge.hinge_limit_min = -29
	hinge.move_hinge(deg_to_rad(-28))
	time_travel_light.time_travel()
	await get_tree().create_timer(1.5).timeout
	for obj in time_impacted_objects:
		obj.toggle_time()

func _process(delta: float) -> void:
	if test:
		if Input.is_action_just_pressed("ui_accept"):
			time_travel()
	cooldown -= delta
	if cooldown < 0:
		hinge.hinge_limit_min = -35
	

func _on_pull_lever_hinge_moved(angle: Variant) -> void:
	if angle < -30:
		time_travel()
