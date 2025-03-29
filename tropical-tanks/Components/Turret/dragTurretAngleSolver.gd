extends Node
class_name DragTurretAngleSolver

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
	
	var horizontal_dist: float = Vector2(turret_position.x, turret_position.z).distance_to(
		Vector2(target_position.x, target_position.z))
	var height_diff: float = target_position.y - turret_position.y
	var g: float = -gravity
	var solutions: Array = []
	
	# Use w(x) equation for targets below turret
	var domain = calculate_w_domain(drag, shell_velocity, g, height_diff)
	var lower_bound = domain[0]
	var upper_bound = domain[1]
	
	if is_inf(lower_bound) or is_inf(upper_bound):
		#print("Invalid w(x) domain")
		pass
	else:
		var x_max = find_vertex(drag, shell_velocity, g, height_diff, lower_bound, upper_bound)
		if not is_inf(x_max):
			# Find solutions with derivative-aware bracketing
			var left_sol = solve_branch(
				drag, shell_velocity, g, height_diff, horizontal_dist,
				lower_bound, x_max, true)
			var right_sol = solve_branch(
				drag, shell_velocity, g, height_diff, horizontal_dist,
				x_max, upper_bound, false)
			
			if left_sol != -INF: solutions.append(left_sol)
			if right_sol != -INF: solutions.append(right_sol)
	if height_diff > 0.0:
		if not is_inf(lower_bound):
			var solution = solve_newton(
				func(x: float): return f_new(x, drag, shell_velocity, g, height_diff) - horizontal_dist,
				lower_bound + 0.001,
				lower_bound,
				MAX_ANGLE
			)
			if solution != -INF: solutions.append(solution)
	
	# Select appropriate solution
	if solutions.is_empty():
		#print("No solutions found, using default angle")
		return DEFAULT_ANGLE
	
	solutions.sort()
	return solutions[-1] if mortar_mode else solutions[0]

func solve_branch(
	d_r: float, p_w: float, g: float, h: float, d_s: float,
	lower: float, upper: float, is_left_branch: bool) -> float:
	
	var x0 = lerp(lower, upper, 0.5)
	var solution = -INF
	
	# Adjust initial guess based on derivative direction
	for i in 3:  # Limited attempts to find good initial guess
		var current_deriv = w_prime(x0, d_r, p_w, g, h)
		var valid_deriv = (is_left_branch and current_deriv > 0) or (!is_left_branch and current_deriv < 0)
		
		if valid_deriv:
			solution = solve_newton(
				func(x: float): return w(x, d_r, p_w, g, h) - d_s,
				x0,
				lower,
				upper
			)
			if solution != -INF: break
		
		# Nudge search direction based on branch
		x0 = lerp(x0, upper if is_left_branch else lower, 0.2)
	
	return solution

func find_vertex(d_r: float, p_w: float, g: float, h: float, lower: float, upper: float) -> float:
	# Newton-Raphson for maximum finding
	var x = (lower + upper) * 0.5
	var dx: float = 1e-6
	var max_iter: int = 100
	
	for i in max_iter:
		var grad = w_prime(x, d_r, p_w, g, h)
		var grad_prime = (w_prime(x + dx, d_r, p_w, g, h) - w_prime(x - dx, d_r, p_w, g, h)) / (2.0 * dx)
		
		if absf(grad) < THRESHOLD:
			return x
		if absf(grad_prime) < 1e-12:
			break
			
		x -= grad / grad_prime
		x = clampf(x, lower, upper)
	
	# Fallback to simple gradient search
	var step = 0.001
	var improvement = true
	while improvement and absf(step) > 1e-6:
		var prev_grad = w_prime(x, d_r, p_w, g, h)
		x += step
		x = clampf(x, lower, upper)
		var new_grad = w_prime(x, d_r, p_w, g, h)
		
		if absf(new_grad) < absf(prev_grad):
			step *= 1.2
		else:
			step *= -0.5
			improvement = absf(new_grad) < absf(prev_grad)
	
	return x

func solve_newton(f: Callable, x0: float, lower: float, upper: float) -> float:
	var x = clampf(x0, lower, upper)
	var dx: float = 1e-6
	var max_iter: int = 50
	
	for i in max_iter:
		var fx = f.call(x)
		var fp = (f.call(x + dx) - f.call(x - dx)) / (2.0 * dx)
		
		if absf(fx) < THRESHOLD:
			return x
		if absf(fp) < 1e-12:
			break
			
		x -= fx / fp
		x = clampf(x, lower, upper)
	
	return -INF

#region Physics Equations -----------------------------------------------------
func calculate_w_domain(d_r: float, p_w: float, g: float, h: float) -> Array:
	if h < 0.0:
		return [-PI/2.0, PI/2.0]
	var arg = sqrt(2.0 * g * (exp(h * d_r) - 1.0)) / (p_w * sqrt(d_r))
	return [asin(clampf(arg, -1.0, 1.0)), PI/2.0] if arg <= 1.0 else [-INF, -INF]

func calculate_f_domain(d_r: float, p_w: float, g: float, h: float) -> float:
	var arg = sqrt(2.0 * g * (exp(h * d_r) - 1.0)) / (p_w * sqrt(d_r))
	return asin(clampf(arg, -1.0, 1.0)) if arg <= 1.0 else -INF

func w(x: float, d_r: float, p_w: float, g: float, h: float) -> float:
	var t = T(x, d_r, p_w, g)
	var s = S(x, d_r, p_w, g, h, t)
	var inner = 1.0 + (d_r * 0.5) * p_w * cos(x) * (t + s)
	return (2.0 / d_r) * log(inner) if inner > 0.0 else -INF

func w_prime(x: float, d_r: float, p_w: float, g: float, h: float) -> float:
	var dx: float = 1e-6
	return (w(x + dx, d_r, p_w, g, h) - w(x - dx, d_r, p_w, g, h)) / (2.0 * dx)

func T(x: float, d_r: float, p_w: float, g: float) -> float:
	var denom = sqrt(g * d_r * 0.5)
	var arg = p_w * sin(x) * sqrt(d_r / (2.0 * g))
	return atan(arg) / denom

func S(x: float, d_r: float, p_w: float, g: float, h: float, t: float) -> float:
	var arg = atan(p_w * sin(x) * sqrt(d_r / (2.0 * g)))
	var num = cos(arg - t * sqrt(g * d_r * 0.5))
	var den = cos(arg) * exp(h * d_r * 0.5)
	if is_zero_approx(den): return -INF
	var a = num / den
	return sqrt(2.0 / (g * d_r)) * acosh(a) if a >= 1.0 else -INF

func f_new(x: float, d_r: float, p_w: float, g: float, h: float) -> float:
	var sqrt_term = sqrt(d_r / (2.0 * g))
	var term1 = atan(p_w * sin(x) * sqrt_term)
	var cos_term = cos(term1) * exp(h * d_r * 0.5)
	if cos_term < -1.0 or cos_term > 1.0: return -INF
	var term2 = acos(cos_term)
	var inner = 1.0 + p_w * cos(x) * sqrt_term * (term1 - term2)
	return (2.0 / d_r) * log(inner) if inner > 0.0 else -INF
#endregion
