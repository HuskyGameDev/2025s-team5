extends Node3D


@onready var canvasLayer = $CanvasLayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# func _unhandled_input(event):
	# if event is InputEventKey:
		# var justPressed = event.is_pressed() and not event.is_echo()
		# if justPressed and event.keycode == KEY_ESCAPE:
			# get_tree().change_scene_to_file("res://Scenes/devmenu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/devmenu.tscn")
	

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/HubMenu/hub_menu.tscn")
	


var SETTINGS_SCENE = preload("res://Scenes/MainMenu/Settings.tscn")
func _on_settings_button_pressed() -> void:
	$CanvasLayer/CenterContainer/PanelContainer/VBoxContainer.hide()
	$CanvasLayer/CenterContainer2.hide()
	var scene = SETTINGS_SCENE.instantiate()
	canvasLayer.add_child(scene)
	


var HOWTOPLAY_SCENE = preload("res://Scenes/MainMenu/HowToPlay.tscn")
func _on_how_to_play_button_pressed() -> void:
	$CanvasLayer/CenterContainer/PanelContainer/VBoxContainer.hide()
	$CanvasLayer/CenterContainer2.hide()
	var scene = HOWTOPLAY_SCENE.instantiate()
	canvasLayer.add_child(scene)


var CREDITS_SCENE = preload("res://Scenes/MainMenu/Credits.tscn")
func _on_credits_button_pressed() -> void:
	$CanvasLayer/CenterContainer/PanelContainer/VBoxContainer.hide()
	$CanvasLayer/CenterContainer2.hide()
	var scene = CREDITS_SCENE.instantiate()
	canvasLayer.add_child(scene)
