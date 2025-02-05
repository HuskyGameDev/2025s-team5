extends Node3D

@export var tank : Tank

var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false
	
}


func _physics_process(delta: float) -> void:
	tank.controls = controls
	
	
	
func _on_timer_timeout() -> void:
	var r = randi_range(0, 4)
	if (r == 0):
		controls["backward"] = false
		controls["forward"] = true
	if (r == 1):
		controls["forward"] = false
		controls["backward"] = true
	if (r == 2):
		controls["turn_right"] = false
		controls["turn_left"] = true
	if (r == 3):
		controls["turn_left"] = false
		controls["turn_right"] = true
	if (r == 4):
		controls["turn_right"] = false
		controls["turn_left"] = false
		controls["backward"] = false
		controls["forward"] = false
