extends Node

@export var texture1 : Texture
@export var texture2 : Texture
@export var blend_factor : float = 3.0

func _ready() -> void:
	await Engine.get_main_loop().process_frame
	var image_1 = texture1.get_image()
	var image_2 = texture2.get_image()
	var res = ImageTexture.create_from_image(blend_images([image_1, image_2]))
	ResourceSaver.save(res,"res://Art/Images/Blends/Test.tres")

## Blends and array of Images into one Image
## The output Image will be the same size as the first Image in the array
func blend_images(images:Array[Image]) -> Image:
	# If no images provided return null
	if not images or images.is_empty():
		return null
	# If only one image is provided then return that one
	if images.size() == 1:
		return images[0]

	# Create a new Image with the size of the first Image in the array
	var xsize = images[0].get_width()
	var ysize = images[1].get_height()
	var out_image = Image.create(xsize, ysize, false, Image.FORMAT_RGBA8)

	for x in xsize:
		for y in ysize:
			var blend = images[0].get_pixel(x,y) * clamp(images[1].get_pixel(x,y).r * blend_factor,0.0,1.0)
			
			out_image.set_pixel(x,y,blend)

	return out_image
