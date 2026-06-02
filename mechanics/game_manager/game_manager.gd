extends Node
class_name GameManager

signal game_progressed(new_stage: Stage)

enum Stage {
	TO_TIME_TRAVEL1,
	TO_PICK_UP_CROWBAR,
	TO_BREAK_LOCKBOX,
	TO_SNAP_PUZZLE,
	TO_TIME_TRAVEL2,
	END
}

var current_stage: Stage = Stage.TO_TIME_TRAVEL1

func _time_travelled():
	if current_stage == Stage.TO_TIME_TRAVEL1:
		progress(Stage.TO_PICK_UP_CROWBAR)
	elif current_stage == Stage.TO_TIME_TRAVEL2:
		progress(Stage.END)

func _crowbar_taken():
	if current_stage == Stage.TO_PICK_UP_CROWBAR:
		progress(Stage.TO_BREAK_LOCKBOX)

func _lockbox_opened():
	if current_stage == Stage.TO_BREAK_LOCKBOX:
		progress(Stage.TO_SNAP_PUZZLE)

func _puzzle_snapped():
	if current_stage == Stage.TO_SNAP_PUZZLE:
		progress(Stage.TO_TIME_TRAVEL2)

func progress(new_stage: Stage):
	game_progressed.emit(new_stage)
	current_stage = new_stage


func _on_time_travel_controller_time_travel_ended(_present: bool) -> void:
	_time_travelled()
