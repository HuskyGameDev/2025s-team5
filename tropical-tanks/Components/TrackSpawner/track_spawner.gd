extends Node3D

var TRACK = preload("res://Components/Track/Track.tscn")
@onready var track_cast : RayCast3D = $RayCast3D

func _on_timer_timeout() -> void:
	if track_cast.is_colliding():
		var track : Track = TRACK.instantiate()
		var terrain = track_cast.get_collider().get_parent().get_parent()
		track.rotation = global_rotation
		track.position = track_cast.get_collision_point()
		
		track.terrain = terrain
		terrain.add_child(track)
		
		var floor_normal = track_cast.get_collision_normal()
		track.basis.y = floor_normal
		track.basis.x = -track.basis.z.cross(floor_normal)
		track.basis = track.basis.orthonormalized()

		
