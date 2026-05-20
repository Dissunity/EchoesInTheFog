extends Node

## Light that will produce the time travel effect
@export var time_travel_light: OmniLight3D
@export var environment: WorldEnvironment
@export var moonlight: DirectionalLight3D

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
	cooldown = 20
	for obj in time_impacted_objects:
		obj.toggle_time()
	
	var tween = get_tree().create_tween()
	var energy = moonlight.light_energy
	tween.tween_property(moonlight, "light_energy", 0, 1)
	tween.parallel().tween_property(environment.environment, "fog_light_energy", 0, 1)
	tween.parallel().tween_property(environment.environment, "ambient_light_sky_contribution", 0, 1)
	tween.tween_interval(2)
	tween.tween_property(time_travel_light, "light_energy", 500, 1.5).set_ease(Tween.EASE_OUT)
	
	for i in range(12):
		tween.tween_property(time_travel_light, "light_energy", 100, 0.2)
		tween.tween_property(time_travel_light, "light_energy", 500, 0.2)

	tween.tween_property(time_travel_light, "light_energy", 0, 2).set_ease(Tween.EASE_OUT)
	

	tween.tween_property(moonlight, "light_energy", energy, 5)
	tween.parallel().tween_property(environment.environment, "fog_light_energy", 1, 5)
	tween.parallel().tween_property(environment.environment, "ambient_light_sky_contribution", 0.8, 5)


	await tween.finished

func _process(delta: float) -> void:
	if test:
		if Input.is_action_just_pressed("ui_accept"):
			_time_travel()
	cooldown -= delta

func _on_pull_lever_hinge_moved(angle: Variant) -> void:
	if angle <= hinge.hinge_limit_min + 1 and cooldown <= 0:
		_time_travel()
