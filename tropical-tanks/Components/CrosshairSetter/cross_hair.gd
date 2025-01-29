extends Node2D
class_name CrosshairSetter

@export var crosshair_size : Vector2 = Vector2(50, 50)

var reticle : CompressedTexture2D = preload("res://Art/Images/CrossHairALLWHITE.svg")
var blocked_reticle = preload("res://Art/Images/CrossHairBlocked.svg")
var outOfRange_reticle : CompressedTexture2D = preload("res://Art/Images/CrossHairBlocked.svg")

func _ready() -> void:
	
	set_crosshair(0)

func set_crosshair(crosshair_index) -> void:
	var reticle_image = reticle.get_image()
	var outOfRange_reticle_image = outOfRange_reticle.get_image()
	reticle_image.resize(crosshair_size.x, crosshair_size.y, Image.INTERPOLATE_CUBIC)
	outOfRange_reticle_image.resize(crosshair_size.x, crosshair_size.y, Image.INTERPOLATE_CUBIC)
	if crosshair_index == 0:
		Input.set_custom_mouse_cursor(reticle_image, 0, crosshair_size/2)
	if crosshair_index == 1:
		Input.set_custom_mouse_cursor(outOfRange_reticle_image, 0, crosshair_size/2)
