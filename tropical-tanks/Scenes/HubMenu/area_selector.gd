extends Control

@onready var menu = get_parent().get_parent()
var area = "res://Scenes/Areas/area_tropical.tscn"


func _on_exit_button_pressed() -> void:
	queue_free()


func _on_tropical_area_area_button_pressed(area_button : AreaButton) -> void:
	menu.area = area_button.area
	var AREA_NAME = area_button.area_name
	menu.currentAreaLabel.text = "Current: " + AREA_NAME
	menu.bottomPanelBackground.texture = area_button.area_panel_background
