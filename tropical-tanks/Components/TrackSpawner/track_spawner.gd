extends Node3D

var TRACK = preload("res://Components/Track/Track.tscn")

func _on_timer_timeout() -> void:
	if $RayCast3D.is_colliding():
		var track : Node3D = TRACK.instantiate()
		track.rotation = global_rotation
		track.position = $RayCast3D.get_collision_point()
		get_tree().root.add_child(track)
