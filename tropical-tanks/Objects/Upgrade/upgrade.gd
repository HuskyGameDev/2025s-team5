extends Node3D

# Placeholder int 
# REPLACE WITH ENUM
@export var Upgrade : int

# Passed when an object enters the collection area
func _on_collection_area_3d_body_entered(body: Node3D) -> void:
	print("Upgrade collected!")
	queue_free()
