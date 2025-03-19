extends Node

@export var tank : TankChassis

var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false,
	"shoot" = false,
}



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	tank.controls = controls
	controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false,
	"shoot" = false,
	}
	
	if Input.is_action_pressed("tank_forward"):
		controls["forward"] = true
		
	if Input.is_action_pressed("tank_backward"):
		controls["backward"] = true
		
	if Input.is_action_pressed("tank_turn_left"):
		controls["turn_left"] = true
		
	if Input.is_action_pressed("tank_turn_right"):
		controls["turn_right"] = true
		
	if Input.is_action_pressed("tank_shoot"):
		controls["shoot"] = true
