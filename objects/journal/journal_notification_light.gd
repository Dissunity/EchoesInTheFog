extends OmniLight3D
class_name ShiningLight

var _shining = true


func start_shining():
	_shining = true

func stop_shining():
	light_energy = 0
	time = 0
	_shining = false

var time = 0

func _process(delta):
	if _shining:
		time += delta
		light_energy = sin(time * 3) + 1
