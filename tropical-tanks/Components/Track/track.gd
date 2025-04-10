extends Node3D
class_name Track

@onready var sprite_3d: Sprite3D = $Sprite3D

var terrain : Node3D

var life_time : float = 0
var max_life_time : float = 30.0
var track_color : Color = Color(.4,.3,0)

func _ready() -> void:
	if terrain is Terrain3D:
		var xpos : int = global_position.x + terrain.xsize/2
		var zpos : int = global_position.z + terrain.zsize/2
		
		track_color = terrain.colorImage.get_pixel(xpos,zpos) * 0.7
	sprite_3d.modulate = track_color
		

func _process(delta: float) -> void:
	
	var modulation = 1-life_time/max_life_time
	sprite_3d.modulate.a = modulation
	life_time += delta #* GLOBAL.aging_factor
	
	if life_time >= max_life_time:
		queue_free()
		
