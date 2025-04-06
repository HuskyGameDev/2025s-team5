extends Node3D

var terrain : Node3D
@onready var mat :StandardMaterial3D = %MeshInstance3D.get_surface_override_material(0)
var crater_color = Color(0.4,0.2,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation.y = randf() * TAU
	
	if terrain is Terrain3D:
		var xpos : int = global_position.x + terrain.xsize/2
		var zpos : int = global_position.z + terrain.zsize/2
		
		crater_color = terrain.colorImage.get_pixel(xpos,zpos) * 0.7
		
	mat.albedo_color = crater_color


var life_time : float = 0
var max_life_time : float = 30.0

func _process(delta: float) -> void:
	life_time += delta
	
	
	if life_time >= max_life_time:
		queue_free()
