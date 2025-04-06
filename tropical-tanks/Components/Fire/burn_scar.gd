extends Decal

var life_time = 0.0
var max_life_time = randf_range(30.0,90.0)

func _process(delta: float) -> void:
	var modulation = 1-life_time/max_life_time
	modulate.a = modulation
	life_time += delta
	
	if life_time >= max_life_time:
		queue_free()
