extends Node

signal time_travel_initiated
signal time_travel_ended(present: bool)

@export_category("Global Nodes")
@export var moonlight: DirectionalLight3D
@export var water_node: Node3D
## Light that will produce the time travel effect
@export var time_travel_light: OmniLight3D
## World environment which will be affected by time travelling
@export var environment: WorldEnvironment
@export var player: Player
@export var monster: Monster
@export var past_lighthouse: Lighthouse

@export_category("Timeline Folders")
@export var past_folder: Node3D
@export var present_folder: Node3D

@export_category("Past Colors")
@export var past_moon_color: Color = Color("b4c8ff")
@export var past_fog_color: Color = Color("141b2b")
@export var past_sky_top: Color = Color("040814")
@export var past_sky_horizon: Color = Color("1a233a")
@export var past_water_deep: Color = Color("0a1e3f")
@export var past_water_shallow: Color = Color("1f4277")

@export_category("Present Colors")
@export var present_moon_color: Color = Color("b4c8ff")
@export var present_fog_color: Color = Color("141b2b")
@export var present_sky_top: Color = Color("040814")
@export var present_sky_horizon: Color = Color("1a233a")
@export var present_water_deep: Color = Color("0a1e3f")
@export var present_water_shallow: Color = Color("1f4277")



## Only enable this to easily test the time travelling effect
## When enabled, within a single press of ENTER, the time travel will happen
@export var test: bool = false

@export_category("Time Traveling Sounds")
@export var audio_stream_player: AudioStreamPlayer
@export var foghorn_sound: AudioStream
@export var lights_out_sound: AudioStream
@export var time_traveling_sound: AudioStream

var _water_material: ShaderMaterial 

var cooldown = 0
var _present: bool = true

func _ready() -> void:
	# Duplicate Environment & Sky resources so code doesn't permanently overwrite files
	if environment and environment.environment:
		environment.environment = environment.environment.duplicate()
		if environment.environment.sky:
			environment.environment.sky = environment.environment.sky.duplicate()
			if environment.environment.sky.sky_material:
				environment.environment.sky.sky_material = environment.environment.sky.sky_material.duplicate()
				
	# Find the MeshInstance3D inside the Water Node3D and duplicate its material
	if water_node:
		for child in water_node.get_children():
			if child is MeshInstance3D:
				var mat = child.get_surface_override_material(0)
				if mat:
					_water_material = mat.duplicate()
					child.set_surface_override_material(0, _water_material)
				break 


func _time_travel():
	time_travel_initiated.emit()
	_present = !_present
	cooldown = 30

	var old_fog_light_energy = environment.environment.fog_light_energy
	var old_ambient_light_sky_contribution = environment.environment.ambient_light_sky_contribution
	
	audio_stream_player.stream = foghorn_sound
	audio_stream_player.play(1.5)
	await audio_stream_player.finished
	audio_stream_player.pitch_scale = 0.5
	audio_stream_player.play()
	await audio_stream_player.finished
	audio_stream_player.pitch_scale = 1
	audio_stream_player.stream = lights_out_sound
	audio_stream_player.play()
	var tween = get_tree().create_tween()
	tween.tween_property(environment.environment, "fog_light_energy", 0, 2)
	tween.parallel().tween_property(environment.environment, "ambient_light_sky_contribution", 0, 2)
	tween.parallel().tween_property(moonlight, "light_energy", 0, 2)
	tween.tween_interval(1)
	await tween.finished
	past_lighthouse.rotating_spotlight.visible = false
	
	audio_stream_player.stream = time_traveling_sound
	audio_stream_player.play()
	player.disable_movement()
	tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(time_travel_light, "light_energy", 20, 3)
	for i in range(16):
		tween.tween_property(time_travel_light, "light_energy", 1, 0.25)
		tween.tween_property(time_travel_light, "light_energy", 20, 0.25)

	# Swap the folders at the peak of the flash 
	tween.tween_callback(func():
		var sky_mat = null
		if environment and environment.environment and environment.environment.sky:
			sky_mat = environment.environment.sky.sky_material
		

		if not _present:
			past_folder.visible = true
			past_folder.process_mode = Node.PROCESS_MODE_INHERIT
			present_folder.visible = false
			present_folder.process_mode = Node.PROCESS_MODE_DISABLED
			
			if moonlight: moonlight.light_color = past_moon_color
			if environment: environment.environment.fog_light_color = past_fog_color
			if sky_mat:
				sky_mat.sky_top_color = past_sky_top
				sky_mat.sky_horizon_color = past_sky_horizon
			if _water_material:
				_water_material.set_shader_parameter("color_deep", past_water_deep)
				_water_material.set_shader_parameter("color_shallow", past_water_shallow)
	)

	if not _present:
		player.enable_movement()
		tween.tween_property(time_travel_light, "light_energy", 0, 2).set_ease(Tween.EASE_OUT)
		tween.tween_property(environment.environment, "fog_light_energy", old_fog_light_energy, 7)
		tween.tween_property(moonlight, "light_energy", 0.5, 7)
		tween.parallel().tween_property(environment.environment, "ambient_light_sky_contribution", old_ambient_light_sky_contribution, 7)
	
	await tween.finished
	
	if _present:
		monster.spawn()
		await get_tree().create_timer(1.75).timeout
		past_folder.visible = false
		return
	
	time_travel_ended.emit(_present)

func _process(delta: float) -> void:
	if test and cooldown <= 0:
		if Input.is_action_just_pressed("ui_accept"):
			_time_travel()
	cooldown -= delta

func _on_lighthouse_foghorn_lever_pulled() -> void:
	_time_travel()
