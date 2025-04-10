extends Control


func _on_back_pressed() -> void:
	close()
	
#var parent_menu
func close():
	#if parent_menu.has_method("popup_closed"):
		#parent_menu.popup_closed()
	get_parent().get_child(0).show()
	queue_free()

@onready var fps_label: Label = $PanelContainer/VBoxContainer/TitleContainer/FPSLabel
@onready var volume_slider: HSlider = $PanelContainer/VBoxContainer/Volume/VolumeSlider

func _ready() -> void:
	volume_slider.value = AudioServer.get_bus_volume_db(0)+80

func _process(delta: float) -> void:
	fps_label.text = "FPS: " + str(int(Engine.get_frames_per_second()))

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
			close()

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

# Mappings implementation
# var MAPPINGS_SCENE = preload("res://Scenes/MainMenu/KeyMappings.tscn")
# func _on_button_mappings_pressed() -> void:
	# var scene = MAPPINGS_SCENE.instantiate()
	# add_child(scene)


func _on_fps_show_toggled(toggled_on: bool) -> void:
	if toggled_on:
		fps_label.hide()
	else:
		fps_label.show()


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value-80)
	
