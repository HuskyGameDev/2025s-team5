extends Control

const VERSION = "alpha 1"

var levels = [
"res://Scenes/hub_menu.tscn",
"res://Scenes/mat_test_scene.tscn",
"res://Scenes/area_tropical.tscn",
"res://Scenes/jake_test_scene.tscn",
"res://Scenes/test_scene_empty.tscn",
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
