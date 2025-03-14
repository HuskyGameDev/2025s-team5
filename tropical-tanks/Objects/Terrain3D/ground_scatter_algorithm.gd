extends Node3D
class_name GroundScatteringAlgorithm

# GENERALIZED PLANT PLACEMENT FUNCTION
func spawn_plant(plants : Array, radius_range : Vector2, plant_count_range : Vector2 ,min_dist: float, max_dist: float, count: int):
	var centers = poisson_disk_sampling(min_dist, max_dist, count)
	
	for center in centers:
		var cluster_radius = randf_range(radius_range.x, radius_range.y)
		var plant_count : int = randi_range(plant_count_range.x, plant_count_range.y)
		var placed_plants = []
		for i in range(plant_count):
			var angle = randf() * TAU #Random angle in radians
			var distance = randf_range(0, cluster_radius)
			var pos = center + Vector2(cos(angle), sin(angle)) * distance
			var grid_pos = get_grid_position(pos)
			
			if is_position_valid(grid_pos) and !is_too_close(grid_pos, placed_plants, min_tree_distance):
				var tree = plants.pick_random().instantiate()
				place_plant(tree, grid_pos, true)
				placed_plants.append(grid_pos)
				
				# Occasionally spawn a fern under a tree (15% chance)
				if randf() > 0.85:
					var fern_pos = grid_pos + Vector2(randf_range(-1, 1), randf_range(-1, 1))
					fern_pos = get_grid_position(fern_pos)
					if is_position_valid(fern_pos):
						var fern = GROUND_SCATTER7.instantiate()
						place_plant(fern, fern_pos, true)

########################################
# FUNCTION: Poisson Disk Sampling
########################################
func poisson_disk_sampling(min_dist: float, max_dist: float, count: int) -> Array:
	var points = []
	var attempts = 0
	# Use a random radius between min and max. (This example uses a single radius per call.)
	var sample_radius = randf_range(min_dist, max_dist)
	
	while points.size() < count and attempts < 1000:
		var pos = Vector2(randf_range(0, xsize), randf_range(0, zsize))
		var valid = true
		for existing in points:
			if pos.distance_to(existing) < sample_radius:
				valid = false
				break
		if valid:
			points.append(pos)
		attempts += 1
	return points
