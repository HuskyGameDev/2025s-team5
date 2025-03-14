@tool
extends Node3D

@export var MODEL : PackedScene :
	set(value):
		MODEL.can_instantiate()
		model_scene = MODEL.instantiate()
		
		
var model_scene : Node3D :
	set(value):
		model_scene = value
		for child in $MeshRoot.get_children():
			child.queue_free()
		$MeshRoot.add_child(model_scene)
		
@export var is_collidable : bool = false


func death():
	queue_free()

func _ready() -> void:
	pass
	
