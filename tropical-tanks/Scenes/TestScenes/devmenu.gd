extends Control

const VERSION = "alpha 2"

var levels = [
"res://Scenes/Menus/MainMenu/main_menu.tscn",
"res://Scenes/Menus/HubMenu/hub_menu.tscn",
"res://Scenes/Areas/Tropical_Area.tscn",
"res://Scenes/Areas/Desert_Area.tscn",
]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#dir_contents("res://Levels/")
	for level in levels:
		var level_button = Button.new()
		level_button.text = level
		level_button.pressed.connect(_on_button_pressed.bind(level))
		$VBoxContainer.add_child(level_button)
	$VBoxContainer/Label.text = VERSION
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_button_pressed(level) -> void:
	get_tree().change_scene_to_file(level)
