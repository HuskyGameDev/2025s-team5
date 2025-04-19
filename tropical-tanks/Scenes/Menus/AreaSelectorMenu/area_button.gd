extends Control

class_name AreaButton

signal area_button_pressed(area)

@export var area_panel_background : Texture 
@export var icon : Texture = preload("res://Art/Images/DebugTexture.png")
@export var area : PackedScene

@export_multiline var text : String


func _ready() -> void:
	$HBoxContainer/TextureRect.texture = icon
	#$TropicalButton.texture_normal = icon
	#$TropicalButton.texture_pressed = icon
	$HBoxContainer/RichTextLabel.text = text

func _on_button_pressed() -> void:
	emit_signal("area_button_pressed",self)
