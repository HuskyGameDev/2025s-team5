extends Node3D
class_name Turret

@export var target_position : Vector3 = Vector3(0,0,0)

var shell_parameters : ShellParameter = ShellParameter.new()
var BARREL = preload("res://Components/Turret/barrel.tscn")

@export var split_barrels : int = 1 :
	set(value):
		split_barrels = value
		set_barrels()
		# if Engine.is_editor_hint():
		
		
@export var double_barrels : int = 1 :
	set(value):
		double_barrels = value
		set_barrels()
		# if Engine.is_editor_hint():

var initial_shot_power = 20
var shoot_cooldown = 1.0

@onready var bearing = $TurretHub/Bearing
@onready var aim_laser = %AimLaser

var split_barrel_holder : Array = []

func _ready() -> void:
	set_barrels()
	shell_parameters.bounces_left = 0

func set_barrels() -> void:
	if !bearing:
		return
	var angular_spread_per_split_barrel = .1
	var position_spread_per_split_barrel = .3 / split_barrels
	var double_barrels_radius = .06 + double_barrels * 0.01
	
	for child in bearing.get_children():
		if child is Barrel:
			child.queue_free()
	
	split_barrel_holder = []
	$Timer.wait_time = shoot_cooldown / double_barrels
	
	for i_split_barrel in split_barrels:
		var double_barrel_holder : Array[Barrel] = []
		for i_double_barrel in double_barrels:
			var barrel : Barrel = BARREL.instantiate()
			barrel.position.x += - position_spread_per_split_barrel * split_barrels  + position_spread_per_split_barrel * (i_split_barrel + 0.5) * 2
			#barrel.position.x += - double_barrels_radius * double_barrels + double_barrels_radius * (w + 0.5) * 2
			
			if double_barrels > 1:
				var angle = deg_to_rad(360/double_barrels)
				var two_barrel_shift = int(double_barrels == 2) * deg_to_rad(90)
				barrel.position += Vector3(0,double_barrels_radius,0).rotated(Vector3(0,0,1), angle * (i_double_barrel) + two_barrel_shift)

			barrel.rotation.y = angular_spread_per_split_barrel * split_barrels - angular_spread_per_split_barrel * (i_split_barrel + 0.5) * 2
			barrel.turret = self
			bearing.add_child(barrel)
		
			double_barrel_holder.append(barrel)
		split_barrel_holder.append(double_barrel_holder)


@onready var drag_turret_angle_solver : DragTurretAngleSolver = DragTurretAngleSolver.new()
@onready var basic_turret_angle_solver : BasicTurretAngleSolver = BasicTurretAngleSolver.new()
var minimum_shot_distance : float = 6.0
var shot_obstructed : bool = false
@export var use_drag_solver : bool = false ## Uses drag solver if [code]true[/code]
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return #Do not do this code while in editor
	if %AimLaser.is_colliding():
		shot_obstructed = true
	else:
		shot_obstructed = false
	
	look_at(target_position)
	$TurretHub.global_position = global_position
	rotation.x = clamp(rotation.x, -0.4, 2)
	$TurretHub.global_rotation = global_rotation * Vector3(0,1,0)
	
	var initial_shot_velocity = initial_shot_power/shell_parameters.mass
	var best_turret_angle = 0
	if use_drag_solver:
		best_turret_angle = drag_turret_angle_solver.calculate_turret_angle(global_position,target_position, initial_shot_velocity, shell_parameters.drag, shell_parameters.mass, shell_parameters.gravity.y, false)
	else:
		best_turret_angle = basic_turret_angle_solver.calculate_turret_angle($TurretHub/Bearing/AimCalculateLocation.global_position,target_position, initial_shot_velocity, shell_parameters.gravity.y, false)
	#print(best_turret_angle)
	
	var current_turret_angle = move_toward(bearing.rotation.x,best_turret_angle, delta)
	bearing.rotation.x = current_turret_angle


var shoot_cooled_down = true
func _on_timer_timeout() -> void:
	shoot_cooled_down = true
	
var i = 0
func shoot():
	if shot_obstructed:
		return
	if shoot_cooled_down:
		for split_barrel in split_barrel_holder:
			split_barrel[i].fire_shell()
			i += 1
			i = i % double_barrels
		shoot_cooled_down = false
		$Timer.start()
