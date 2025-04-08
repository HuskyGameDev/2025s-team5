extends Control

@onready var fps = $MarginContainer/PanelContainer/VBoxContainer/PanelContainer/Top/currentFPS

func _process(delta: float) -> void:
	fps.text = "FPS: " + str(int(Engine.get_frames_per_second()))

func _ready() -> void:
	$MarginContainer/PanelContainer/VBoxContainer/Volume/Volume.value = AudioServer.get_bus_volume_db(0)+80

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value-80)
	

func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
			get_window().move_to_center()
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
			get_window().move_to_center()
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))
			get_window().move_to_center()


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_parent().get_child(0).get_child(0).get_child(0).show()
			get_parent().get_child(1).show()
			queue_free()


func _on_back_pressed() -> void:
	get_parent().get_child(0).get_child(0).get_child(0).show()
	get_parent().get_child(1).show()
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

var MAPPINGS_SCENE = preload("res://Scenes/MainMenu/KeyMappings.tscn")
func _on_button_mappings_pressed() -> void:
	var scene = MAPPINGS_SCENE.instantiate()
	add_child(scene)


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
