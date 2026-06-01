extends Node

signal time_travel_initiated
signal time_travel_ended


## Light that will produce the time travel effect
@export var time_travel_light: OmniLight3D

## World environment which will be affected by time travelling
@export var environment: WorldEnvironment

## Foghorn lever hinge which when pulled triggers the time travelling
@export var hinge: XRToolsInteractableHinge

@export var puzzle_holder_collision_shape: CollisionShape3D

## Only enable this to easily test the time travelling effect
## When enabled, within a single press of ENTER, the time travel will happen
@export var test: bool = false
@export var lockbox: Lockbox

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export_category("Time Traveling Sounds")
@export var foghorn_sound: AudioStream
@export var lights_out_sound: AudioStream
@export var time_traveling_sound: AudioStream

var cooldown = 0

func _ready():
	hinge.hinge_moved.connect(_on_pull_lever_hinge_moved)
	puzzle_holder_collision_shape.disabled = true

func _time_travel():
	time_travel_initiated.emit()
	cooldown = 30
	puzzle_holder_collision_shape.disabled = !puzzle_holder_collision_shape.disabled
	lockbox.is_present = !lockbox.is_present

	var old_fog_light_energy = environment.environment.fog_light_energy
	var old_ambient_light_sky_contribution = environment.environment.ambient_light_sky_contribution
	
	audio_stream_player.stream = foghorn_sound
	audio_stream_player.play(1.5)
	await get_tree().create_timer(3).timeout
	
	audio_stream_player.stream = lights_out_sound
	audio_stream_player.play()
	var tween = get_tree().create_tween()
	tween.tween_property(environment.environment, "fog_light_energy", 0, 2)
	tween.parallel().tween_property(environment.environment, "ambient_light_sky_contribution", 0, 2)
	tween.tween_interval(1)
	await tween.finished
	
	audio_stream_player.stream = time_traveling_sound
	audio_stream_player.play()
	tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(time_travel_light, "light_energy", 100, 3)
	for i in range(20):
		tween.tween_property(time_travel_light, "light_energy", 100, 0.2)
		tween.tween_property(time_travel_light, "light_energy", 500, 0.2)

	tween.tween_property(time_travel_light, "light_energy", 0, 2).set_ease(Tween.EASE_OUT)
	tween.tween_property(environment.environment, "fog_light_energy", old_fog_light_energy, 7)
	tween.parallel().tween_property(environment.environment, "ambient_light_sky_contribution", old_ambient_light_sky_contribution, 7)
	
	await tween.finished
	time_travel_ended.emit()

func _process(delta: float) -> void:
	if test and cooldown <= 0:
		if Input.is_action_just_pressed("ui_accept"):
			_time_travel()
	cooldown -= delta

func _on_pull_lever_hinge_moved(angle: Variant) -> void:
	if angle <= hinge.hinge_limit_min + 1 and cooldown <= 0:
		_time_travel()
