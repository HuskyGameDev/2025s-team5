extends Node2D

@export var crosshair_size : Vector2 = Vector2(50, 50)

var reticle : CompressedTexture2D = preload("res://Art/Images/CrossHairALLWHITE.svg")
var blocked_reticle = preload("res://Art/Images/CrossHairBlocked.svg")
var outOfRange_reticle = preload("res://Art/Images/CrossHairOutOfRange.svg")

func _ready() -> void:
	var reticle_image = reticle.get_image()
	reticle_image.resize(crosshair_size.x, crosshair_size.y, Image.INTERPOLATE_CUBIC)
	Input.set_custom_mouse_cursor(reticle_image, 0, crosshair_size/2)
