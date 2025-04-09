extends Node3D

var area = preload("res://Scenes/Areas/Tropical_Area.tscn")
@onready var canvasLayer = $CanvasLayer
@onready var currentAreaLabel : Label = $CanvasLayer/PanelContainer/AreaBox/CurrentArea/CurrentAreaLabel
@onready var bottomPanelBackground = $CanvasLayer/PanelBackground


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(area)


var AREASELECTOR_SCENE = preload("res://Scenes/HubMenu/AreaSelector.tscn")
func _on_area_select_pressed() -> void:
	var scene = AREASELECTOR_SCENE.instantiate()
	canvasLayer.add_child(scene)
