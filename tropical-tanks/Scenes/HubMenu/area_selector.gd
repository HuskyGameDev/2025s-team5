extends Control

@onready var menu = get_parent().get_parent()
var area = "res://Scenes/Areas/area_tropical.tscn"



func _on_exit_button_pressed() -> void:
	queue_free()


func _on_tropical_area_area_button_pressed(area: Variant) -> void:
	menu.area = area
