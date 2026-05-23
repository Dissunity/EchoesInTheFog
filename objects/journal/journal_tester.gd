extends Node

@export var journal: Journal
var sl: ShiningLight

enum Stage {
	TO_TIME_TRAVEL1,
	TO_PICK_UP_CROWBAR,
	TO_TIME_TRAVEL2,
	TO_BREAK_LOCKBOX,
	TO_TIME_TRAVEL3,
	TO_SNAP_PUZZLE,
	TO_GO_UP_STAIRS
}

func _ready() -> void:
	sl = journal.shining_light



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_page_down"):
		sl.stop_shining()
		await get_tree().create_timer(2).timeout
		if journal.current_stage == Stage.TO_TIME_TRAVEL1:
			print("yes")
			journal._on_game_manager_time_travelled()
		else:
			print("no")
			print(journal.current_stage)
