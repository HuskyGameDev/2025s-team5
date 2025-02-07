extends Node3D

var area = "res://Scenes/area_tropical.tscn"
# Called when the node enters the scene tree for the first time.


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(area)
