extends Node3D

var time = 0
func _physics_process(delta: float) -> void:
	if get_parent() is Node3D:
		global_position = get_parent().global_position
	$Sprite3D.modulate = Color(1,0,0,1-time)
	time += delta


func _on_timer_timeout() -> void:
	queue_free()
