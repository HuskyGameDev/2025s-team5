@tool
extends Node3D
class_name Pickup


@export var upgrade : Upgrade :
	set(value):
		upgrade = value
		if upgrade:
			$Sprite3D.texture = upgrade.image
		else: 
			$Sprite3D.texture = load("res://Art/Images/CrossHairOutOfRange.svg")

@export var rarity_color : Color = Color(0,0.5,0):
	set(value):
		rarity_color = value
		$Sprite3D2.modulate = rarity_color

func _ready() :
	if upgrade.image:
		$Sprite3D.texture = upgrade.image
	if upgrade.rarity_color:
		rarity_color = upgrade.rarity_color
	$Sprite3D2.modulate = rarity_color
	# Waits a frame before becoming pick-up-able
	await get_tree().process_frame
	$CollectionArea3D.monitoring = true

# Passed when an object enters the collection area
func _on_collection_area_3d_body_entered(body: Node3D) -> void:
	if(body.has_method("on_upgrade_pickup") and body.is_in_group("Player")):
		body.on_upgrade_pickup(upgrade)
		print("Pickup collected!")
		queue_free()
