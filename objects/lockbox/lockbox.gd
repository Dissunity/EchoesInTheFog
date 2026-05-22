extends Node3D

signal lockbox_opened

@onready var lockbox: Node3D = $lockbox/RigidBody3D/lockbox_destructables
@onready var lockbox_destruct: Node3D = $lockbox_destruct
@onready var lockbox_collision: CollisionShape3D = $lockbox/RigidBody3D/DestructableCollisionShape3D6
@export var locked_object: XRToolsPickable
@export var INTENSITY:float = 12.0;

var locked = true
var hit_count = 0

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	locked_object.enabled = false
	_freeze_all_pieces(locked)
	_toggle_visibility(true)
	_toggle_collisions(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _toggle_collisions(disable_mesh: bool):
	lockbox_collision.disabled = disable_mesh
	#print("lockbox_collision is disabled: ", lockbox_collision.disabled)
	
	var lockbox_destruct_collision_shapes = lockbox_destruct.find_children("*", "CollisionShape3D")
	for lockbox_destruct_shape in lockbox_destruct_collision_shapes:
		lockbox_destruct_shape.disabled = not disable_mesh
		#print("lockbox_destruct_shape is disabled: ", lockbox_destruct_shape.disabled )

func _toggle_visibility(visible: bool):
	lockbox.visible = visible
	lockbox_destruct.visible = not visible
	
func _hit():
	
	locked = hit_count < MIN_HITS
	#print("Is locked: ", locked)

	if hit_count == 0:
		#print("Hitcount is 0 ")
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
			# Puzzle is pickable
			locked_object.enabled = true
			lockbox_opened.emit()


func _freeze_all_pieces(should_freeze: bool):
	var all_pieces = lockbox_destruct.find_children("*", "RigidBody3D")
	for piece in all_pieces:
		if piece is RigidBody3D:
			piece.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
			piece.freeze = should_freeze

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		#print("Button pressed")
		_hit()
	
