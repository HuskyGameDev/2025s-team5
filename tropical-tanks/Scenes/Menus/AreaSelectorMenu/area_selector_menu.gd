extends Control

var direct_to_area = true

@onready var menu = get_parent().get_parent()
var area = "res://Scenes/Areas/area_tropical.tscn"



func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			close()

func _on_exit_button_pressed() -> void:
	close()


func close():
	#if parent_menu.has_method("popup_closed"):
		#parent_menu.popup_closed()
	get_parent().get_child(0).show()
	queue_free()

func _on_area_button_pressed(area_button: Variant) -> void:
	if direct_to_area:
		get_tree().change_scene_to_packed(area_button.area)
		return
	menu.area = area_button.area
	var AREA_NAME = area_button.area_name
	menu.currentAreaLabel.text = "Current: " + AREA_NAME
	menu.bottomPanelBackground.texture = area_button.area_panel_background
