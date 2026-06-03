extends Node3D

@export var base_energy: float = 1.0
@export var flicker_range: float = 2.4
@export var flicker_speed: float = 0.7

@onready var flame_light: OmniLight3D = $FlameLight
@onready var flame_mesh_1: MeshInstance3D = $FlameMesh1
@onready var flame_mesh_2: MeshInstance3D = $FlameMesh2

var noise: FastNoiseLite
var time_passed: float = 0.0

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.frequency = 0.5
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	time_passed = randf() * 1000.0 

func _process(delta: float) -> void:
	time_passed += delta * flicker_speed
	var noise_val = noise.get_noise_1d(time_passed)
	var current_brightness = base_energy + (noise_val * flicker_range)
	

	flame_light.light_energy = current_brightness
	
	# Update the shader material on the first mesh
	var mat1 = flame_mesh_1.get_active_material(0) as ShaderMaterial
	if mat1:
		mat1.set_shader_parameter("flicker_sync", current_brightness)
		
	# Update the shader material on the second mesh
	var mat2 = flame_mesh_2.get_active_material(0) as ShaderMaterial
	if mat2:
		mat2.set_shader_parameter("flicker_sync", current_brightness)
