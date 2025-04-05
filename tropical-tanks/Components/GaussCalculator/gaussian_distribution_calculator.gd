extends Node
class_name GaussianDistributionCalculator

func _ready() -> void:
	calculate_gaussian_image()

func calculate_gaussian_image():
	var gaussian_dist = Image.create(512,512,false,Image.FORMAT_RGB8)
	var xsize = gaussian_dist.get_size().x
	var ysize = gaussian_dist.get_size().y
	for x in xsize:
		for y in ysize:
			var r = Vector2(x,y).distance_to(Vector2(xsize/2,ysize/2)) / (xsize/4)
			gaussian_dist.set_pixel(x,y,exp(-(pow(r,2))) * Color(1,1,1) )
	#gaussian_dist.save_png("res://Components/Crater/GaussianDistribution.png")
