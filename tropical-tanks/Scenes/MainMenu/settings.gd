extends Control

@onready var fps = $MarginContainer/PanelContainer/VBoxContainer/Top/currentFPS


func _process(delta: float) -> void:
	fps.text = "FPS: " + str(int(Engine.get_frames_per_second()))


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
	

func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			queue_free()


func _on_back_pressed() -> void:
	queue_free()


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			Engine.max_fps = 0
		1:
			Engine.max_fps = 144
		2:
			Engine.max_fps = 60
		3:
			Engine.max_fps = 30


func _on_button_mappings_pressed() -> void:
	pass # Replace with function body.


func _on_fps_show_toggled(toggled_on: bool) -> void:
	if (toggled_on == true):
		fps.hide()
	else:
		fps.show()


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
