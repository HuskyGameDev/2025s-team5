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


func _physics_process(delta: float) -> void:
	for wet_body : Hitbox in wet_bodies:
		if wet_body:
			wet_body.water_depth = global_position.y - wet_body.global_position.y
		else:
			wet_bodies.erase(wet_body)


func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Hitbox:
		wet_bodies.append(area)

func _on_area_3d_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Hitbox:
		area.water_depth = 0
