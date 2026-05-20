extends OmniLight3D
class_name TimeTravelLight

@export var moonlight: Light3D

## Call this function to trigger the time travel visual effect
func time_travel():
	var tween = get_tree().create_tween()
	var energy = moonlight.light_energy
	
	tween.tween_property(self, "light_energy", 500, 1.5).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(moonlight, "light_energy", 0, 1.5).set_ease(Tween.EASE_OUT)
	tween.tween_interval(3)
	tween.tween_property(self, "light_energy", 0, 1.5).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(moonlight, "light_energy", energy, 1.5).set_ease(Tween.EASE_OUT)

	await tween.finished
