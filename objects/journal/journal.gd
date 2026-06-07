extends Node3D
class_name Journal

signal opened
signal closed

var is_open = false

@onready var decal_left: JournalTextDecal = $RigidBody/Armature/Skeleton3D/LeftPageAttachment/Decal
@onready var decal_right: JournalTextDecal = $RigidBody/Armature/Skeleton3D/RightPageAttachment/Decal
@onready var shining_light: OmniLight3D = $RigidBody/JournalNotificationLight
@onready var pickable: XRToolsPickable = $RigidBody
@onready var left_page: SubViewport = $LeftPage
@onready var right_page: SubViewport = $RightPage

func toggle_open():
	if is_open:
		close_journal()
	else:
		open_journal()

func open_journal():
	if is_open:
		return
	$AnimationPlayer.play("ArmatureAction")
	$RigidBody/BookOpeningAudio.play()
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
	await get_tree().create_timer(0.7).timeout
	$RigidBody/BookOpeningAudio.play()
	await get_tree().create_timer(0.35).timeout
	_turn_decal_off()


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
