extends Control

@onready var menu = get_parent().get_parent()
var area = "res://Scenes/Areas/area_tropical.tscn"

func _on_tropical_button_pressed() -> void:
	area = "res://Scenes/Areas/area_tropical.tscn"
	menu.area = area


func _on_exit_button_pressed() -> void:
	queue_free()


func _on_driving_test_pressed() -> void:
	area = "res://Scenes/driving_test_scene.tscn"
	menu.area = area
