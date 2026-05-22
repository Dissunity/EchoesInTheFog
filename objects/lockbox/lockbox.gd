extends Node3D

@onready var lockbox: Node3D = $lockbox/RigidBody3D/lockbox_destructables
@onready var lockbox_destruct: Node3D = $lockbox_destruct
@onready var lockbox_collision: CollisionShape3D = $lockbox/RigidBody3D/DestructableCollisionShape3D6
@export var locked_object: XRToolsPickable

var lockbox_unlocked = false
var min_hits = 3
var hit_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	locked_object.enabled = false
	_toggle_collisions()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _toggle_collisions():
	var lockbox_collision_shapes = lockbox.find_children("*", "CollisionShape3D")
	var lockbox_destruct_collision_shapes = lockbox_destruct.find_children("*", "CollisionShape3D")

	var disable = false

	for lockbox_shape in lockbox_collision_shapes:
		pass
		#present_shape.disabled = not disable
		#print("Present shape ", present_shape.name, " disabled status: ", present_shape.disabled)

	for lockbox_destruct_shape in lockbox_destruct_collision_shapes:
		pass
		#past_shape.disabled = disable
		#print("Past shape ", past_shape.name, " disabled status: ", past_shape.disabled)
