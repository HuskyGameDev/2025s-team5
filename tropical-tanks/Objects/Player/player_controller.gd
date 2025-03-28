extends Node

@export var tank : TankChassis
@onready var health_manager : HealthManager = tank.health_manager

@onready var progress_bar: ProgressBar = $CanvasLayer/PanelContainer/ProgressBar


var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false,
	"shoot" = false,
}

func update_gui():
	progress_bar.max_value = health_manager.max_health
	progress_bar.value = health_manager.health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	update_gui()
	
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
