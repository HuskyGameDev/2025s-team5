extends Node3D

@onready var decal : Decal  = $Decal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	decal.sorting_use_aabb_center = false
	decal.sorting_offset = randi()



var life_time : float = 0
var max_life_time : float = 30.0

func _process(delta: float) -> void:
	decal.modulate.a = clampf( 2 * (1 - sqrt((life_time/max_life_time))), 0.0, 1.0)
	life_time += delta
	
	if life_time >= max_life_time:
		queue_free()
