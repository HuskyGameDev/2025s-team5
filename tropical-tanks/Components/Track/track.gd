extends Node

func _ready() -> void:
	pass
	

var life_time : float = 0
var max_life_time : float = 30.0

func _process(delta: float) -> void:
	#var material : StandardMaterial3D = $MeshInstance3D.get_surface_override_material(0)
	#material.albedo_color = Color(0,1-life_time/max_life_time,0)
	life_time += delta
	
	if life_time >= max_life_time:
		queue_free()
		
