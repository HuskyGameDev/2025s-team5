extends Node3D

signal pickup()

# Passed when an object enters the collection area
func _on_collection_area_3d_body_entered(body: Node3D) -> void:
	if(!body.is_in_group("Enemy")):
		print("Upgrade collected!")
		emit_signal("pickup")
		queue_free()
