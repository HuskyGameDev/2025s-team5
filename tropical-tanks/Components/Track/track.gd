extends Node
	
@onready var sprite_3d: Sprite3D = $Sprite3D

var life_time : float = 0
var max_life_time : float = 30.0
var track_color : Color = Color(.4,.3,0)

func _ready() -> void:
	sprite_3d.modulate = track_color

func _process(delta: float) -> void:
	
	var modulation = 1-life_time/max_life_time
	sprite_3d.modulate.a = modulation
	life_time += delta
	
	if life_time >= max_life_time:
		queue_free()
		
