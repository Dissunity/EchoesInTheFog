extends Area3D


@export var label: Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Hellow"
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	label.text = "Area entered"
	print("Area entered")


func _on_area_exited(area: Area3D) -> void:
	label.text = "Area exited"
	print("Area exited")


func _on_body_entered(body: Node3D) -> void:
	label.text = "Body entered"
	print("Body entered")


func _on_body_exited(body: Node3D) -> void:
	label.text = "Body exited"
	print("Body exited")
