extends Node

## Light that will produce the time travel effect
@export var time_travel_light: TimeTravelLight

## All the objects which have their past and present variants which will switch upon time travel
@export var time_impacted_objects: Array[TimeImpactedObject]

## Foghorn lever hinge which when pulled triggers the time travelling
@export var hinge: XRToolsInteractableHinge

## Only enable this to easily test the time travelling effect
## When enabled, within a single press of ENTER, the time travel will happen
@export var test: bool = false

var cooldown = 0

func _ready():
	hinge.hinge_moved.connect(_on_pull_lever_hinge_moved)

func _time_travel():
	cooldown = 10
	time_travel_light.time_travel()
	await get_tree().create_timer(1.5).timeout
	for obj in time_impacted_objects:
		obj.toggle_time()

func _process(delta: float) -> void:
	if test:
		if Input.is_action_just_pressed("ui_accept"):
			_time_travel()
	cooldown -= delta

func _on_pull_lever_hinge_moved(angle: Variant) -> void:
	if angle <= hinge.hinge_limit_min + 1 and cooldown <= 0:
		_time_travel()
