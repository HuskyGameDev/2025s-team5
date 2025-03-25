extends Resource
class_name SpawnExplosion

@export var explosion_power : Vector2 = Vector2(1.0,1.0)
const EXPLOSION = preload("res://Components/Explosion/explosion.tscn")
func trigger_effect(node : Node3D) -> void:
	#assert(OBJECT, "Spawn Object requires an object")
	var explosion : Explosion = EXPLOSION.instantiate()
	explosion.explosion_power = randf_range(explosion_power.x,explosion_power.y)
	explosion.position = node.global_position
	node.get_tree().root.add_child(explosion)
