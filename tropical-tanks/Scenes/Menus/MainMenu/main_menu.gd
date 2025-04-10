extends Node3D


@onready var canvasLayer = $CanvasLayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			queue_free()

# func _unhandled_input(event):
	# if event is InputEventKey:
		# var justPressed = event.is_pressed() and not event.is_echo()
		# if justPressed and event.keycode == KEY_ESCAPE:
			# get_tree().change_scene_to_file("res://Scenes/devmenu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/devmenu.tscn")
	
const AREA_SELECTOR_MENU = preload("res://Scenes/Menus/AreaSelectorMenu/area_selector_menu.tscn")
func _on_start_button_pressed() -> void:
	hide_menu()
	var scene = AREA_SELECTOR_MENU.instantiate()
	canvasLayer.add_child(scene)
	
func popup_closed():
	canvasLayer.get_child(0).show()
	
func hide_menu():
	canvasLayer.get_child(0).hide()

const SETTINGS_MENU = preload("res://Scenes/Menus/SettingsMenu/settings_menu.tscn")
func _on_settings_button_pressed() -> void:
	hide_menu()
	var scene = SETTINGS_MENU.instantiate()
	scene.parent_menu = self
	canvasLayer.add_child(scene)
	
const HOW_TO_PLAY_MENU = preload("res://Scenes/Menus/HowToPlayMenu/how_to_play_menu.tscn")
func _on_how_to_play_button_pressed() -> void:
	hide_menu()
	var scene = HOW_TO_PLAY_MENU.instantiate()
	canvasLayer.add_child(scene)

const CREDITS_MENU = preload("res://Scenes/Menus/CreditsMenu/credits_menu.tscn")
func _on_credits_button_pressed() -> void:
	hide_menu()
	var scene = CREDITS_MENU.instantiate()
	canvasLayer.add_child(scene)
