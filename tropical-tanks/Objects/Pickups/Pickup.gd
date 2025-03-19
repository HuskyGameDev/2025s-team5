extends Node3D

@export var upgrade : Upgrade

func _ready() :
	if upgrade.image:
		$Sprite3D.texture = upgrade.image

# Passed when an object enters the collection area
func _on_collection_area_3d_body_entered(body: Node3D) -> void:
	if(body.has_method("on_upgrade_pickup")):
		body.on_upgrade_pickup(upgrade)
		print("Pickup collected!")
		queue_free()
