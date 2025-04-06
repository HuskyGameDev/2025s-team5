@tool
extends HSplitContainer
signal area_button_pressed(area)

@export var icon : Texture
@export var area : PackedScene

@export_multiline var text : String


func _ready() -> void:
	$TropicalButton.texture_normal = icon
	$RichTextLabel.text = text


func _on_tropical_button_pressed() -> void:
	emit_signal("area_button_pressed",area)
