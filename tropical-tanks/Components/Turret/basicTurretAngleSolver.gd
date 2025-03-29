extends Node
class_name BasicTurretAngleSolver

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
		return deg_to_rad(45.0)
	
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
	var final_angle = a1 if mortar_angle else a2
	
	return deg_to_rad(final_angle)
