extends Node3D

signal opened
signal closed

var is_open = false
@export var debug = false


func _process(_delta: float) -> void:
	if debug and Input.is_action_just_pressed("ui_accept"):
		toggle_open()

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

func close_journal():
	if not is_open:
		return
	$AnimationPlayer.play_backwards("ArmatureAction")
	is_open = false
	closed.emit()
