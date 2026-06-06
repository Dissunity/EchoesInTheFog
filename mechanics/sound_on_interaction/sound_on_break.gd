extends AudioStreamPlayer3D


func play_sound(hit_num):
	if hit_num == 1:
		pitch_scale = 1.1
	elif hit_num == 2:
		pitch_scale = 0.9
	else:
		pitch_scale = 0.5
	play()
