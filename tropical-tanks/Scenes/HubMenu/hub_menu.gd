extends Node3D

var area = "res://Scenes/Areas/area_tropical.tscn"
# Called when the node enters the scene tree for the first time.
@onready var canvasLayer = $CanvasLayer

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(area)


var AREASELECTOR_SCENE = preload("res://Scenes/HubMenu/AreaSelector.tscn")
func _on_area_select_pressed() -> void:
	var scene = AREASELECTOR_SCENE.instantiate()
	canvasLayer.add_child(scene)
