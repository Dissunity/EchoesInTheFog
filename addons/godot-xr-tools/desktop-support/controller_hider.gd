@tool
@icon("res://addons/godot-xr-tools/editor/icons/function.svg")
class_name XRToolsDesktopControllerHider
extends Node

## XR Tools Controller Hider
##
## This script hides controller if XR is not active.

var _pointer_disabler := false
var _last_xr_active := true

# Parent controller
@onready var _controller : XRController3D = XRHelpers.get_xr_controller(self)


var world


func is_xr():
	return world.is_xr

func _ready() -> void:
	var root = get_tree().root
	world = root.get_node("World")
	if !is_xr:
		_pointer_disabler = true

# Add support for is_xr_class on XRTools classes
func is_xr_class(xr_name:  String) -> bool:
	return xr_name == "XRToolsDesktopControllerHider"

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or !is_inside_tree():
		return
	if _pointer_disabler:
		get_parent().enabled=is_xr()
	elif is_instance_valid(_controller):
		_controller.visible=is_xr()
	_last_xr_active=is_xr()


# This method verifies the movement provider has a valid configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Check the controller node
	if !XRHelpers.get_xr_controller(self) \
		and !XRTools.find_xr_ancestor(self,"*","XRToolsFunctionPointer"):
		warnings.append("This node must be within a branch of an XRController3D node")

	# Return warnings
	return warnings
