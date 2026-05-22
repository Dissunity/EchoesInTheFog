extends Node3D

signal opened
signal closed

var is_open = false

@onready var decal_left: JournalTextDecal = $Armature/Skeleton3D/LeftPageAttachment/Decal
@onready var decal_right: JournalTextDecal = $Armature/Skeleton3D/RightPageAttachment/Decal
@onready var label_left: Label = $LeftPage/Label
@onready var label_right: Label = $RightPage/Label
@onready var shining_light = $JournalNotificationLight
@export var debug = false


var parent: XRToolsPickable

enum Stage {
	TO_TIME_TRAVEL1,
	TO_PICK_UP_CROWBAR,
	TO_TIME_TRAVEL2,
	TO_BREAK_LOCKBOX,
	TO_TIME_TRAVEL3,
	TO_SNAP_PUZZLE,
	TO_GO_UP_STAIRS
}

var current_stage: Stage = Stage.TO_TIME_TRAVEL1



func toggle_open():
	if is_open:
		close_journal()
	else:
		open_journal()

func open_journal():
	if is_open:
		return
	$AnimationPlayer.play("ArmatureAction")
	is_open = true
	opened.emit()
	await get_tree().create_timer(0.1).timeout
	_turn_decal_on()
	shining_light.stop_shining()

func close_journal():
	if not is_open:
		return
	$AnimationPlayer.play_backwards("ArmatureAction")
	is_open = false
	closed.emit()
	await get_tree().create_timer(1.05).timeout
	_turn_decal_off()

func change_text(text_left: String, text_right: String):
	label_left.text = text_left
	label_right.text = text_right
	await get_tree().create_timer(0.1).timeout
	decal_left.update_text_projection()
	current_stage = Stage.TO_GO_UP_STAIRS
	decal_right.update_text_projection()
	if !is_open:
		shining_light.start_shining()

func _turn_decal_off():
	decal_left.visible = false
	decal_left.update_text_projection()
	decal_right.visible = false
	decal_right.update_text_projection()

func _turn_decal_on():
	decal_left.visible = true
	decal_left.update_text_projection()
	decal_right.visible = true
	decal_right.update_text_projection()

func _ready() -> void:
	parent = get_parent()
	decal_left.update_text_projection.call_deferred()
	decal_right.update_text_projection.call_deferred()
	change_text("There is a lockbox with an important mechanical part. But you need a tool to open it. There once was a crowbar here that could be used to open it. ", "Go to the past and find it there by pulling the lever at the top floor.")

func _process(_delta: float) -> void:
	if parent.is_picked_up() and !is_open:
		open_journal()
	elif !parent.is_picked_up() and is_open:
		close_journal()

func _on_game_manager_time_travelled() -> void:
	if current_stage == Stage.TO_TIME_TRAVEL1:
		current_stage = Stage.TO_PICK_UP_CROWBAR
		change_text("There should be a crowbar somewhere in the lighthouse.", "Go downstairs and take the crowbar.")
	if current_stage == Stage.TO_TIME_TRAVEL2:
		current_stage = Stage.TO_BREAK_LOCKBOX
		change_text("You should be able to open the lockbox now.", "Open the lockbox with the crowbar.")
	if current_stage == Stage.TO_TIME_TRAVEL3:
		current_stage = Stage.TO_SNAP_PUZZLE
		change_text("Find the cabinet again.", "Put the mechanical part in the cabinet.")

func _on_game_manager_crowbar_taken() -> void:
	if current_stage == Stage.TO_PICK_UP_CROWBAR:
		current_stage = Stage.TO_TIME_TRAVEL2
		change_text("There isn't a lockbox at this time.", "Take the crowbar with you and bring it to the present.")

func _on_game_manager_lockbox_opened() -> void:
	if current_stage == Stage.TO_BREAK_LOCKBOX:
		current_stage = Stage.TO_TIME_TRAVEL3
		change_text("The cabinet where the mechanical part should go is broken.", "Take the mechanical part and bring it to the past by time travelling.")

func _on_game_manager_puzzle_snapped() -> void:
	if current_stage == Stage.TO_SNAP_PUZZLE:
		current_stage = Stage.TO_GO_UP_STAIRS
		change_text("The mechanical part is now installed.", "There is something going on above. Go to the top floor.")

func _on_game_manager_player_went_upstairs() -> void:
	if current_stage == Stage.TO_GO_UP_STAIRS:
		return # no more hints, it is game over
