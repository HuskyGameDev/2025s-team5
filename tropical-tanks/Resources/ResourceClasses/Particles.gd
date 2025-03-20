extends Resource
class_name Particles

@export var PARTICLES : PackedScene
func trigger_effect(node : Node3D) -> void:
	var particles : GPUParticles3D = PARTICLES.instantiate()
	particles.position = node.global_position
	node.get_tree().root.add_child(particles)
	particles.emitting = true
	print("particles!!")
	#particles.finished.connect(call_deferred("queue_free"))
	
