extends Node3D
class_name TankController


var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false
	
}


func _physics_process(delta: float) -> void:
	pass
	
	

func _on_timer_timeout() -> void:
	controls["forward"] = !controls["forward"]
