extends Resource
class_name SpawnPickup

var PICKUP = preload("res://Objects/Pickups/Pickup.tscn")
@export var offset : Vector3 = Vector3(0,0,0)

@export var upgrade_pools : Array[UpgradePool]

func trigger_effect(node : Node3D) -> void:
	print("WAWDASDAWD")
	if upgrade_pools.size() > 0:
		var upgrade_pool = upgrade_pools.pick_random()
		var pickup : Node3D = PICKUP.instantiate()
		pickup.position = node.global_position + offset
		pickup.upgrade = upgrade_pool.select_upgrade()
		node.get_tree().root.add_child(pickup)
	else:
		push_warning("Upgrade pool is not set")
