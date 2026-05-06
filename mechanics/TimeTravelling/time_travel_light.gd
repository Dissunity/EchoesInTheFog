extends OmniLight3D
class_name TimeTravelLight

func time_travel():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "light_energy", 200, 1.5).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2)
	tween.tween_property(self, "light_energy", 0, 1.5).set_ease(Tween.EASE_OUT)
	await tween.finished
