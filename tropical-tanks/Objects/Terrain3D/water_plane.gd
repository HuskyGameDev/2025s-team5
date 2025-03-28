extends MeshInstance3D
class_name WaterMesh

var shallow_depth : float = 0.0 :## The depth before bodies start taking damage
	set(value):
		shallow_depth = value 
		$Area3D.position.y = -shallow_depth
var wet_bodies = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D.position.y = -shallow_depth
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	wet_bodies.append(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if wet_bodies.has(body):
		wet_bodies.erase(body)

func _physics_process(delta: float) -> void:
	for wet_body in wet_bodies:
		if wet_body:
			if wet_body.has_method("take_damage"):
				var leak_attack : Attack = Attack.new()
				leak_attack.damage = 1
				var wet_body_depth = global_position.y - wet_body.global_position.y
				leak_attack.water_depth = clamp(wet_body_depth,0.0,wet_body_depth)
				wet_body.take_damage(leak_attack)

	
