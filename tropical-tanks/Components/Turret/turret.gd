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



var minimum_shot_distance : float = 3.0
var shot_obstructed : bool = false
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
	var best_turret_angle = (calculate_turret_angle($TurretHub/Bearing/AimCalculateLocation.global_position,target_position,initial_shot_power/shell_parameters.mass, shell_parameters.drag, shell_parameters.gravity.y, false))
	print(best_turret_angle)
	bearing.rotation.x = best_turret_angle

const THRESHOLD: float = 0.0001
const MAX_ANGLE: float = PI/2.0
const DEFAULT_ANGLE: float = PI/4.0

func calculate_turret_angle(
	turret_position: Vector3,
	target_position: Vector3,
	shell_velocity: float,
	drag: float,
	gravity: float = -9.81,
	mortar_mode: bool = false) -> float:
	
	# Calculate target parameters
	var horizontal_dist: float = Vector2(turret_position.x, turret_position.z).distance_to(
		Vector2(target_position.x, target_position.z))
	var height_diff: float = target_position.y - turret_position.y
	var g: float = -gravity
	var solutions: Array = []
	
	if height_diff < 0.0:
		# Use w(x) equation with two solution branches
		var domain = calculate_w_domain(drag, shell_velocity, g, height_diff)
		var lower_bound = domain[0]
		var upper_bound = domain[1]
		
		if is_inf(lower_bound) or is_inf(upper_bound):
			print("No valid domain for w(x)")
		else:
			var x_max = find_vertex(drag, shell_velocity, g, height_diff, lower_bound, upper_bound)
			
			if is_inf(x_max):
				print("No vertex found")
			else:
				print("Found vertex at: ", x_max)
				# Search both branches
				var left_solution = solve_newton(
					func(x: float): return w(x, drag, shell_velocity, g, height_diff) - horizontal_dist,
					lerp(lower_bound, x_max, 0.5),
					lower_bound,
					x_max
				)
				if not is_inf(left_solution):
					solutions.append(left_solution)
					print("Left branch solution: ", left_solution)
				
				var right_solution = solve_newton(
					func(x: float): return w(x, drag, shell_velocity, g, height_diff) - horizontal_dist,
					lerp(x_max, upper_bound, 0.5),
					x_max,
					upper_bound
				)
				if not is_inf(right_solution):
					solutions.append(right_solution)
					print("Right branch solution: ", right_solution)
	else:
		# Use f(x) equation
		var lower_bound = calculate_f_domain(drag, shell_velocity, g, height_diff)
		if is_inf(lower_bound):
			print("No valid f(x) domain")
		else:
			var solution = solve_newton(
				func(x: float): return f_new(x, drag, shell_velocity, g, height_diff) - horizontal_dist,
				lower_bound + 0.001,
				lower_bound,
				MAX_ANGLE
			)
			if not is_inf(solution):
				solutions.append(solution)
				print("f(x) solution: ", solution)
	
	# Select best solution
	if solutions.is_empty():
		print("No solutions found, using default angle")
		return DEFAULT_ANGLE
	
	solutions.sort()
	print("All valid solutions: ", solutions)
	
	if mortar_mode:
		return solutions[-1]  # Highest angle
	return solutions[0]  # Lowest angle

#region Core Calculation Functions --------------------------------------------
func solve_newton(f: Callable, x0: float, lower: float, upper: float) -> float:
	var x: float = clampf(x0, lower, upper)
	var dx: float = 1e-6
	var max_iter: int = 50
	
	for i in max_iter:
		var fx: float = f.call(x)
		var fp: float = (f.call(x + dx) - f.call(x - dx)) / (2.0 * dx)
		
		if absf(fx) < THRESHOLD:
			return x
		if absf(fp) < 1e-12:
			break
			
		x -= fx / fp
		x = clampf(x, lower, upper)
	
	return -INF

func find_vertex(d_r: float, p_w: float, g: float, h: float, lower: float, upper: float) -> float:
	# Newton's method to find where w'(x) = 0
	var x: float = (lower + upper) * 0.5
	var dx: float = 1e-6
	var max_iter: int = 50
	
	for i in max_iter:
		var grad: float = w_prime(x, d_r, p_w, g, h, dx)
		var grad_plus: float = w_prime(x + dx, d_r, p_w, g, h, dx)
		var grad_minus: float = w_prime(x - dx, d_r, p_w, g, h, dx)
		var grad_prime: float = (grad_plus - grad_minus) / (2.0 * dx)
		
		if absf(grad) < THRESHOLD:
			return x
		if absf(grad_prime) < 1e-12:
			break
			
		x -= grad / grad_prime
		x = clampf(x, lower, upper)
	
	# Fallback to gradient ascent
	var lr: float = 0.001
	for j in 1000:
		var current_grad: float = w_prime(x, d_r, p_w, g, h, dx)
		if absf(current_grad) < THRESHOLD:
			return x
		x += lr * current_grad
		x = clampf(x, lower, upper)
	
	return -INF

#region Physics Equations -----------------------------------------------------
func calculate_w_domain(d_r: float, p_w: float, g: float, h: float) -> Array:
	if h < 0.0:
		return [-PI/2.0, PI/2.0]
	else:
		var arg = sqrt(2.0 * g * (exp(h * d_r) - 1.0)) / (p_w * sqrt(d_r))
		if arg > 1.0:
			return [-INF, -INF]
		return [asin(arg), PI/2.0]

func calculate_f_domain(d_r: float, p_w: float, g: float, h: float) -> float:
	var numerator = sqrt(2.0 * g * (exp(h * d_r) - 1.0))
	var denominator = p_w * sqrt(d_r)
	var arg = numerator / denominator
	return asin(arg) if arg <= 1.0 else -INF

func w(x: float, d_r: float, p_w: float, g: float, h: float) -> float:
	var t = T(x, d_r, p_w, g)
	var s = S(x, d_r, p_w, g, h, t)
	var inner = 1.0 + (d_r * 0.5) * p_w * cos(x) * (t + s)
	return (2.0 / d_r) * log(inner) if inner > 0.0 else -INF

func w_prime(x: float, d_r: float, p_w: float, g: float, h: float, dx: float = 1e-6) -> float:
	return (w(x + dx, d_r, p_w, g, h) - w(x - dx, d_r, p_w, g, h)) / (2.0 * dx)

func T(x: float, d_r: float, p_w: float, g: float) -> float:
	var denom = sqrt(g * d_r * 0.5)
	var arg = p_w * sin(x) * sqrt(d_r / (2.0 * g))
	return atan(arg) / denom

func S(x: float, d_r: float, p_w: float, g: float, h: float, t: float) -> float:
	var arg = atan(p_w * sin(x) * sqrt(d_r / (2.0 * g)))
	var num = cos(arg - t * sqrt(g * d_r * 0.5))
	var den = cos(arg) * exp(h * d_r * 0.5)
	if is_equal_approx(den, 0.0): return -INF
	var a = num / den
	if a < 1.0: return -INF
	return sqrt(2.0 / (g * d_r)) * acosh(a)

func f_new(x: float, d_r: float, p_w: float, g: float, h: float) -> float:
	var sqrt_term = sqrt(d_r / (2.0 * g))
	var term1 = atan(p_w * sin(x) * sqrt_term)
	var cos_term = cos(term1) * exp(h * d_r * 0.5)
	if cos_term < -1.0 or cos_term > 1.0: return -INF
	var term2 = acos(cos_term)
	var inner = 1.0 + p_w * cos(x) * sqrt_term * (term1 - term2)
	if inner <= 0.0: return -INF
	return (2.0 / d_r) * log(inner)
#endregion

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
