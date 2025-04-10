extends Node3D

var area = preload("res://Scenes/Areas/Tropical_Area.tscn")
@onready var canvasLayer = $CanvasLayer
@onready var currentAreaLabel : Label = $CanvasLayer/PanelContainer/AreaBox/CurrentArea/CurrentAreaLabel
@onready var bottomPanelBackground = $CanvasLayer/PanelBackground


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(area)

const AREA_SELECTOR_MENU = preload("res://Scenes/Menus/AreaSelectorMenu/area_selector_menu.tscn")
func _on_area_select_pressed() -> void:
	var scene = AREA_SELECTOR_MENU.instantiate()
	canvasLayer.add_child(scene)
