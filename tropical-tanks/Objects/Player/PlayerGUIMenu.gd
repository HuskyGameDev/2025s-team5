extends CanvasLayer

const HOW_TO_PLAY_MENU = preload("res://Scenes/Menus/HowToPlayMenu/how_to_play_menu.tscn")
const SETTINGS_MENU = preload("res://Scenes/Menus/SettingsMenu/settings_menu.tscn")

func _on_settings_button_pressed() -> void:
	var scene = SETTINGS_MENU.instantiate()
	add_child(scene)
	$Control.hide()



func _on_how_to_play_button_pressed() -> void:
	var scene = HOW_TO_PLAY_MENU.instantiate()
	add_child(scene)
	$Control.hide()
