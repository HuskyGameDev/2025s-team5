extends Resource
class_name UpgradePool

@export var upgrade_drop_pool : Array[Upgrade] ## The pool of possible upgrades to drop


func select_upgrade() -> Upgrade:
	var selected_upgrade = upgrade_drop_pool.pick_random()
	return selected_upgrade
