extends Journal
class_name StoryJournal

func _ready() -> void:
	super()

var disabled_process = false

func _process(delta: float) -> void:
	if disabled_process:
		return
	super(delta)
	if $RigidBody.global_position.y < -10:
		disabled_process = true
		var staging: XRToolsStaging = get_tree().root.get_node("Staging")
		staging.load_scene("res://world/world.tscn")
		
