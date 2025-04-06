extends MeshInstance3D
class_name WaterMesh

var shallow_depth : float = 0.0 :## The depth before bodies start taking damage
	set(value):
		shallow_depth = value 
		$Area3D.position.y = -shallow_depth
		
var wet_bodies : Array[Hitbox] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D.position.y = -shallow_depth

func _on_area_3d_area_shape_entered(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	print("POOL")
	if area is Hitbox:
		wet_bodies.append(area)

func _on_area_3d_area_shape_exited(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area is Hitbox:
		area.water_depth = 0


func _on_water_timer_timeout() -> void:
	for i in wet_bodies.size():
		if wet_bodies[i]:
			var wet_body : Hitbox = wet_bodies[i]
			wet_body.water_depth = global_position.y - wet_body.global_position.y
		else:
			wet_bodies.remove_at(i)
			return
