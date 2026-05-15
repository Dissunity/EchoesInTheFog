extends Node3D

signal opened
signal closed

var is_open = false

@onready var decal_left: JournalTextDecal = $Armature/Skeleton3D/LeftPageAttachment/Decal
@onready var decal_right: JournalTextDecal = $Armature/Skeleton3D/RightPageAttachment/Decal
@onready var label_left: Label = $LeftPage/Label
@onready var label_right: Label = $RightPage/Label
@export var debug = false

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
	if debug and Input.is_action_just_pressed("ui_accept"):
		toggle_open()
	if debug and Input.is_action_just_pressed("ui_right"):
		change_text("hello", "world")
