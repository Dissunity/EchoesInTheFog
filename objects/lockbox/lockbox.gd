extends Node3D
class_name Lockbox

signal unlocked

@onready var lockbox: Node3D = $lockbox/RigidBody3D/lockbox_destructables
@onready var lockbox_destruct: Node3D = $lockbox_destruct
@onready var lockbox_collision: CollisionShape3D = $lockbox/RigidBody3D/DestructableCollisionShape3D6
@onready var test_label:Label3D = $TestLabel3D
@onready var hit_box:Area3D = $HitBoxArea3D

@export var mechanical_part: MechanicalPart
@export var INTENSITY:float = 12.0

			
var locked = true
var hit_count = 0
var hit_cooldown = false 
var MIN_HITS = 3



@onready var impact_list_1: Array = ["lockbox_destruct/RigidBody3D11", 
"lockbox_destruct/RigidBody3D17", 
"lockbox_destruct/RigidBody3D18",
"lockbox_destruct/RigidBody3D"]

@onready var impact_list_2: Array = ["lockbox_destruct/RigidBody3D8", 
"lockbox_destruct/RigidBody3D9",
"lockbox_destruct/RigidBody3D12",
"lockbox_destruct/RigidBody3D13",
"lockbox_destruct/RigidBody3D21",
"lockbox_destruct/RigidBody3D3",
"lockbox_destruct/RigidBody3D6"]

@onready var impact_list_3: Array = ["lockbox_destruct/RigidBody3D24",
"lockbox_destruct/RigidBody3D25",
"lockbox_destruct/RigidBody3D26",
"lockbox_destruct/RigidBody3D14",
"lockbox_destruct/RigidBody3D15",
"lockbox_destruct/RigidBody3D16",
"lockbox_destruct/RigidBody3D19",
"lockbox_destruct/RigidBody3D22",
"lockbox_destruct/RigidBody3D2",
"lockbox_destruct/RigidBody3D4",
"lockbox_destruct/RigidBody3D5",
"lockbox_destruct/RigidBody3D7",
"lockbox_destruct/RigidBody3D10"]

@onready var impact_dict: Dictionary = {
	0: impact_list_1,
	1: impact_list_2,
	2: impact_list_3
}

func _ready() -> void:
	_freeze_all_pieces(locked)
	_toggle_visibility(true)
	_toggle_collisions(false)


func _physics_process(_delta: float) -> void:
	if hit_cooldown or hit_count >= MIN_HITS:
		return

	var overlapping_bodies = hit_box.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("Crowbar"):
			hit_cooldown = true
			
			test_label.text = "Hit detected"
			_hit()
			
			await get_tree().create_timer(0.5).timeout
			hit_cooldown = false
			break

func _toggle_collisions(disable_mesh: bool):
	lockbox_collision.disabled = disable_mesh
	
	var lockbox_destruct_collision_shapes = lockbox_destruct.find_children("*", "CollisionShape3D")
	for lockbox_destruct_shape in lockbox_destruct_collision_shapes:
		lockbox_destruct_shape.disabled = not disable_mesh

func _toggle_visibility(new_visible: bool):
	lockbox.visible = new_visible
	lockbox_destruct.visible = not new_visible
	
func _hit():
	
	locked = hit_count < MIN_HITS

	if hit_count == 0:
		_toggle_visibility(false)
		_toggle_collisions(true)
		
	if locked:
		if impact_dict.has(hit_count):
			var current_impact_paths = impact_dict[hit_count]
			for path: String in current_impact_paths:
				var piece = get_node_or_null(path) as RigidBody3D
				if piece:
					piece.freeze = false
					piece.apply_impulse(piece.get_child(0).position *INTENSITY, self.global_position)
		
		hit_count += 1
		
		if hit_count >= MIN_HITS:
			unlocked.emit()
			mechanical_part.pickable.enabled = true


func _freeze_all_pieces(should_freeze: bool):
	var all_pieces = lockbox_destruct.find_children("*", "RigidBody3D")
	for piece in all_pieces:
		if piece is RigidBody3D:
			piece.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
			piece.freeze = should_freeze

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_hit()
