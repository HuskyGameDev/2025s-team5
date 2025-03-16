extends Node3D

var TRACK = preload("res://Objects/Track/Track.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	if $RayCast3D.is_colliding():
		var track : Node3D = TRACK.instantiate()
		track.rotation = global_rotation
		track.position = global_position
		get_tree().root.add_child(track)
