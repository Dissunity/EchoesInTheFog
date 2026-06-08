extends Journal
class_name OnboardingJournal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	await get_tree().create_timer(randf()).timeout
	open_journal()

func _process(_delta: float) -> void:
	pass
