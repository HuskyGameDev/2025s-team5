extends Node3D

var area
# Called when the node enters the scene tree for the first time.
@onready var canvasLayer = $CanvasLayer
@onready var currentArea = $CanvasLayer/PanelContainer/AreaBox/CurrentArea/CurrentArea

#func _on_ready():
	#currentArea.text = "Current: " + 


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(area)


var AREASELECTOR_SCENE = preload("res://Scenes/HubMenu/AreaSelector.tscn")
func _on_area_select_pressed() -> void:
	var area = AREASELECTOR_SCENE.instantiate()
	canvasLayer.add_child(area)
