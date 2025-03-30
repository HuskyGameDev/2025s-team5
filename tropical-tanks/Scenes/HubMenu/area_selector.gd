extends Control

var TROPICAL_SCENE = "res://Scenes/Areas/area_tropical.tscn"
func _on_tropical_button_pressed() -> void:
	get_tree().change_scene_to_file(TROPICAL_SCENE)


func _on_exit_button_pressed() -> void:
	queue_free()
