extends Resource
class_name Particles

@export var PARTICLES : PackedScene
func trigger_effect(node : Node3D) -> void:
	
	# Create and start the particle effect
	var particles : GPUParticles3D = PARTICLES.instantiate()
	particles.position = node.global_position
	node.get_tree().root.add_child(particles)
	particles.emitting = true
	
	# Delete particle after finished
	particles.finished.connect(Callable(particles,"queue_free"))
	
