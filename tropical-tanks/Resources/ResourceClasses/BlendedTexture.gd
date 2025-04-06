#extends ExternalTexture
#class_name BlendedImage
#
#@export var texture1 : CompressedTexture2D
#@export var texture2 : CompressedTexture2D
#
#func _init() -> void:
	#var image1 = texture1.get_image()
	#var image2 = texture2.get_image()
	#
	#var xsize = image1.get_width()
	#var ysize = image1.get_height()
	#image2.resize(xsize,ysize)
	#
	#var image : Image = Image.create_empty(xsize,ysize,false,Image.FORMAT_RGBA8)
	#for x in xsize:
		#for y in ysize:
			#image.set_pixel(x,y,image1.get_pixel(x,y) * image2.get_pixel(x,y).r)
	#var image_texture = ImageTexture.create_from_image(image)
	#load(image_texture)
	
