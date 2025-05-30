extends Node3D
class_name TankController

@export var tank : TankChassis
@export var turrets : Array[Turret]
@export var target : Node3D
@export var targeting_accuracy : float = 0.5


@onready var terrain_checker: RayCast3D = $TerrainChecker

var angle_to_target : float
var angle_to_origin : float
var distance_to_target : float

var water_nearby = false

var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false,
	"shoot" = false
}

func _ready() -> void:
	await get_tree().physics_frame
	if !tank:
		if get_parent() is TankChassis:
			tank = get_parent()
			
	if tank:
		turrets = tank.get_turrets()
var targeting = false
func _physics_process(_delta: float) -> void:
	if tank:
		tank.controls = controls
		if turrets and target:
			for turret in turrets:
				turret.target_position = target.global_position
	
	if target and targeting == true:
		turn_towards_angle(angle_to_target,targeting_accuracy)

	if terrain_checker.is_colliding():
		controls["backward"] = false
		if terrain_checker.get_collision_point().y < 0:
			water_nearby = true
			controls["forward"] = false
			controls["turn_left"] = true
			controls["turn_right"] = false
		elif water_nearby:
			controls["forward"] = true
			water_nearby = false
		if global_position.y < 0:
			turn_towards_angle(angle_to_origin,targeting_accuracy)
			controls["forward"] = true
			
	else:
		controls["forward"] = false
		controls["backward"] = true
		controls["turn_right"] = true
func turn_towards_angle(angle, accuracy):
	if angle > accuracy:
		controls["turn_right"] = false
		controls["turn_left"] = true
	elif angle < -accuracy:
		controls["turn_right"] = true
		controls["turn_left"] = false
	else:
		controls["turn_right"] = false
		controls["turn_left"] = false
		controls["forward"] = true
	
func get_distance_to_target() -> float:
	var distance_to_target = tank.global_position.distance_to(target.global_position)
	return distance_to_target
	
func get_angle_to_target() -> float:
	var angle_to_target = (-tank.global_transform.basis.z).signed_angle_to((target.global_position - tank.global_position) * Vector3(1,0,1), Vector3(0,1,0))
	return angle_to_target
	
func get_angle_to_origin() -> float:
	var angle_to_origin = (-tank.global_transform.basis.z).signed_angle_to((- tank.global_position) * Vector3(1,0,1), Vector3(0,1,0))
	return angle_to_origin
	
	
func _on_timer_timeout() -> void:
	if (randf() < 0.2):
		controls["forward"] = true
		controls["backward"] = false
	if (randf() < 0.1):
		controls["forward"] = false
	match(randi_range(1, 3)):
		1:
			controls["turn_right"] = false
			controls["turn_left"] = true
		2:
			controls["turn_left"] = false
			controls["turn_right"] = true
		3:
			controls["turn_right"] = false
			controls["turn_left"] = false
	
	if target:
		angle_to_target = get_angle_to_target()
		angle_to_origin = get_angle_to_origin()
		distance_to_target = get_distance_to_target()
		if (randf() < 0.8) and distance_to_target < 20:
			controls["shoot"] = true
		else:
			controls["shoot"] = false

		if distance_to_target > 30:
			targeting = true
		else: 
			targeting = false
	else:
		controls["shoot"] = false
	if !target:
		if get_tree().get_nodes_in_group("Player"):
			var player_tank = get_tree().get_nodes_in_group("Player").pick_random()
			target = player_tank
		else:
			var enemy_tank = get_tree().get_nodes_in_group("Enemy").pick_random()
			if enemy_tank != tank:
				target = enemy_tank
