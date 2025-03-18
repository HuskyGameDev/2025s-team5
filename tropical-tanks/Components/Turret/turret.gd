@tool
extends Node3D
class_name Turret

signal change_crosshair(crosshair_index)

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

var split_barrel_holder = []

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
		var double_barrel_holder = []
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


var look_position = Vector3.ZERO
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	look_position = look_position.move_toward(target_position,delta * 30)
	
	look_at(target_position)
	$TurretHub.global_position = global_position
	rotation.x = clamp(rotation.x, -0.4, 2)
	$TurretHub.global_rotation = global_rotation * Vector3(0,1,0)
	var best_turret_angle = deg_to_rad(calculate_turret_angle(global_position,target_position,initial_shot_power/shell_parameters.mass, -9.8, false))
	bearing.rotation.x = best_turret_angle


func calculate_turret_angle(
	turret_position: Vector3,
	target_position: Vector3,
	shell_initial_velocity: float,
	gravity_acceleration: float = -9.8,
	mortar_angle: bool = false) -> float:
	# Calculate horizontal distance (d) and height difference (h)
	var d = Vector2(turret_position.x, turret_position.z).distance_to(Vector2(target_position.x, target_position.z))
	var h = target_position.y - turret_position.y
	var g = -gravity_acceleration  # Convert to positive gravity value
	
	# Check for invalid projectile parameters
	var discriminant = (
		shell_initial_velocity * shell_initial_velocity *
		(shell_initial_velocity * shell_initial_velocity - 2 * g * h) -
		d * d * g * g
	)
	# Return 45 degrees if path is impossible
	if discriminant < 0:
		return 45.0
	
	# Calculate common terms
	var sqrt_term = sqrt(discriminant)
	var denominator = d * d + h * h
	
	# Calculate corrective factor components
	var corrective_factor = (d * d * (-g/sqrt_term - g/(shell_initial_velocity * shell_initial_velocity)) / denominator - (2 * d * d * h * (sqrt_term/(shell_initial_velocity * shell_initial_velocity) - (g * h)/(shell_initial_velocity * shell_initial_velocity) + 1)) / (denominator * denominator))

	# Calculate intermediate terms for angles
	var c1 = (d * d * (1 - (g * h) / (shell_initial_velocity * shell_initial_velocity)) / denominator )
	var c2 = (d * d * sqrt_term) / (shell_initial_velocity * shell_initial_velocity * denominator)
	
	# Calculate both possible angles
	var a1 = acos(sqrt((c1 - c2) / 2.0)) * 180 / PI
	var a2 = -sign(corrective_factor) * acos(sqrt((c1 + c2) / 2.0)) * 180 / PI
	
	# Return selected angle based on mortar flag
	# If mortar_angle is true, select the higher angle, otherwise lower angle.
	return a1 if mortar_angle else a2

var shoot_cooled_down = true
func _on_timer_timeout() -> void:
	shoot_cooled_down = true
	
var i = 0
func shoot():
	if shoot_cooled_down:
		for split_barrel in split_barrel_holder:
			split_barrel[i].fire_shell()
			i += 1
			i = i % double_barrels
		shoot_cooled_down = false
		$Timer.start()
