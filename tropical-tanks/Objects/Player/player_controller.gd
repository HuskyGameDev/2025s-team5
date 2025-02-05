extends Node

@export var tank : Tank

var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false
	
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	tank.controls = controls
	controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false
	}
	
	if Input.is_action_pressed("tank_forward"):
		controls["forward"] = true
		
	if Input.is_action_pressed("tank_backward"):
		controls["backward"] = true
		
	if Input.is_action_pressed("tank_turn_left"):
		controls["turn_left"] = true
		
	if Input.is_action_pressed("tank_turn_right"):
		controls["turn_right"] = true
