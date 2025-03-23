extends Resource
class_name SpawnObject

@export var OBJECT : PackedScene
func trigger_effect(node : Node3D) -> void:
	#assert(OBJECT, "Spawn Object requires an object")
	if OBJECT:
		var object : Node3D = OBJECT.instantiate()
		object.position = node.global_position
		node.get_tree().root.add_child(object)
	else:
		print("Spawn object has no object")
