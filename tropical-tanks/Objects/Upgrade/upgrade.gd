extends Node3D

# Placeholder int 
# REPLACE WITH ENUM
@export var Upgrade : int

@onready var player_tank: Node3D = $"../PlayerRoot"


# Passed when an object enters the collection area
func _on_collection_area_3d_body_entered(body: Node3D) -> void:
	if(!body.is_in_group("Enemy")):
		
		print("Upgrade collected!")
		queue_free()
