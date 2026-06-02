extends Node3D

@export var base_energy: float = 1.5 # Slightly higher for 4 wicks
@export var flicker_range: float = 0.5
@export var flicker_speed: float = 5.0

@onready var flame_light: OmniLight3D = $FlameLight
@onready var flames_container: Node3D = $Flames # The folder holding 8 meshes

var noise: FastNoiseLite
var time_passed: float = 0.0
var active_materials: Array[ShaderMaterial] = []

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.frequency = 0.5
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	time_passed = randf() * 1000.0
	
	# Loop through every mesh inside the Flames node and save its material
	for mesh in flames_container.get_children():
		if mesh is MeshInstance3D:
			var mat = mesh.get_surface_override_material(0) as ShaderMaterial
			if mat:
				active_materials.append(mat)

func _process(delta: float) -> void:
	time_passed += delta * flicker_speed
	var noise_val = noise.get_noise_1d(time_passed)
	var current_brightness = base_energy + (noise_val * flicker_range)
	
	# 1. Update the single physical light
	flame_light.light_energy = current_brightness
	
	# 2. Update every flame material simultaneously
	for mat in active_materials:
		mat.set_shader_parameter("flicker_sync", current_brightness)
