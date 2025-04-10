extends Node

var aging_factor : float = 1.0

const VERSION_BANNER = preload("res://Scenes/Menus/version_banner.tscn")
func _ready() -> void:
	await get_tree().process_frame
	var version_banner = VERSION_BANNER.instantiate()
	get_tree().root.add_child(version_banner)
