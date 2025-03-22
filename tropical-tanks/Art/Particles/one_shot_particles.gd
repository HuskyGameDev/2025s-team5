extends GPUParticles3D

func _ready() -> void:
	emitting = true
	finished.connect(Callable(self,"queue_free"))
