extends Node3D
class_name Journal

signal opened
signal closed

var is_open = false

@onready var decal_left: JournalTextDecal = $RigidBody/Armature/Skeleton3D/LeftPageAttachment/Decal
@onready var decal_right: JournalTextDecal = $RigidBody/Armature/Skeleton3D/RightPageAttachment/Decal
@onready var label_left: Label = $LeftPage/Label
@onready var label_right: Label = $RightPage/Label
@onready var shining_light: OmniLight3D = $RigidBody/JournalNotificationLight
@export var debug = false

@onready var pickable: XRToolsPickable = $RigidBody

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
	decal_left.update_text_projection.call_deferred()
	decal_right.update_text_projection.call_deferred()

func _process(_delta: float) -> void:
	if pickable.is_picked_up() and !is_open:
		open_journal()
	elif !pickable.is_picked_up() and is_open:
		close_journal()

func _on_game_manager_game_progressed(new_stage: GameManager.Stage) -> void:
	change_text(str(new_stage), "")
