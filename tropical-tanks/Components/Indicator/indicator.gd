extends Node3D
class_name Indicator

@export var text : String = "EMPTY"
@export var color : Color # = Color(0.9,0.1,0.1)

var velocity : Vector3 = Vector3(0,3,0)

func _ready() -> void:
	%Label3D.text = text
	%Label3D.modulate = color
	
	
func _process(delta: float) -> void:
	position += velocity * delta
	


func _on_timer_timeout() -> void:
	queue_free()
