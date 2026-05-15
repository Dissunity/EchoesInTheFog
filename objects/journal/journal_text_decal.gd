extends Decal
class_name JournalTextDecal

@export var target_viewport: SubViewport

func update_text_projection():
	if target_viewport:
		var img = target_viewport.get_texture().get_image()
		var img_tex = texture_albedo as ImageTexture
		img_tex.set_image(img)
