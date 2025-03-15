extends Node3D
class_name GroundScatteringAlgorithm

var terrain
func _ready() -> void:
	terrain = get_parent()
	assert(terrain, "Terrain must be set")


# GENERALIZED PLANT PLACEMENT FUNCTION
func spawn_plants(PLANTS : Array, FERNS : Array, fern_chance : float, radius_range : Vector2, min_plant_dist  : float, plant_count_range : Vector2 , FLOWERS : Array, flower_chance : float, poisson_vector : Vector3 = Vector3.ZERO):
	
	var centers = []
	if poisson_vector != Vector3.ZERO:
		centers = poisson_disk_sampling(poisson_vector)
	else:
		for x in range(0, terrain.xsize, 15):
			for z in range(0, terrain.zsize, 15):
				centers.append(Vector2(x, z))
	var clusters = []
	
	for center in centers:
		var cluster_radius = randf_range(radius_range.x, radius_range.y)
		var plant_count : int = randi_range(plant_count_range.x, plant_count_range.y)
		var placed_plants = []
		
		for i in range(plant_count):
			var angle = randf() * TAU #Random angle in radians
			var distance = randf_range(0, cluster_radius)
			var pos = center + Vector2(cos(angle), sin(angle)) * distance
			var grid_pos = get_grid_position(pos)
			
			if is_position_valid(grid_pos) and !is_too_close(grid_pos, placed_plants, min_plant_dist):
				var plant = PLANTS.pick_random()
				place_plant(plant, grid_pos, true)
				placed_plants.append(grid_pos)
				
				# Occasionally spawn a fern under a tree (15% chance)
				if FERNS.size() > 0 and randf() < fern_chance:
					var fern_pos = grid_pos + Vector2(randf_range(-1, 1), randf_range(-1, 1))
					fern_pos = get_grid_position(fern_pos)
					if is_position_valid(fern_pos):
						var fern = FERNS.pick_random()
						place_plant(fern, fern_pos, true)
						
		clusters.append(placed_plants)
	
	if flower_chance > 0.0:
		for cluster in clusters:
			var edge_positions = []
			
			# Determine edge positions for each bush cluster
			for bush_pos in cluster:
				for dx in [-1, 0, 1]:
					for dz in [-1, 0, 1]:
						if dx == 0 and dz == 0:
							continue
						var neighbor_pos = bush_pos + Vector2(dx, dz)
						if !cluster.has(neighbor_pos) and is_position_valid(neighbor_pos):
							edge_positions.append(neighbor_pos)
			
			# Place flowers along the border edges
			for edge_pos in edge_positions:
				if randf() < flower_chance and is_position_valid(edge_pos):
					var flower = FLOWERS.pick_random()
					place_plant(flower, edge_pos, false)

########################################
# FUNCTION: Poisson Disk Sampling
########################################
func poisson_disk_sampling(poisson_vector : Vector3) -> Array:
	var points = []
	var attempts = 0
	var distance_range = Vector2(poisson_vector.x,poisson_vector.y)
	var count = poisson_vector.z
	# Use a random radius between min and max. (This example uses a single radius per call.)
	var sample_radius = randf_range(distance_range.x,distance_range.y)
	
	while points.size() < count and attempts < 1000:
		var pos = Vector2(randf_range(0, terrain.xsize), randf_range(0, terrain.zsize))
		var valid = true
		for existing in points:
			if pos.distance_to(existing) < sample_radius:
				valid = false
				break
		if valid:
			points.append(pos)
		attempts += 1
	return points
	
	
func place_plant(scene_pack: PackedScene, grid_pos: Vector2, random_rotation: bool) -> void:
	var world_pos = terrain.height_data[grid_pos]
	var plant = scene_pack.instantiate()
	plant.position = world_pos
	plant.rotation.y = (randf() * TAU) 
	terrain.add_child(plant)
	terrain.occupied_positions[grid_pos] = true
	print("plant")
	
func get_grid_position(pos: Vector2) -> Vector2:
	return Vector2(clamp(roundi(pos.x), 0, terrain.xsize), clamp(roundi(pos.y), 0, terrain.zsize))
	
func is_position_valid(grid_pos: Vector2) -> bool:
	if not terrain.height_data.has(grid_pos):
		return false
	var h = terrain.height_data[grid_pos].y
	var slope = calculate_slope(grid_pos)
	
	return slope < terrain.steep_slope_threshold and h > terrain.sand_height
		
func is_too_close(pos: Vector2, existing: Array, min_dist: float) -> bool:
	for p in existing:
		if pos.distance_to(p) < min_dist:
			return true
	return false
	
func calculate_slope(grid_pos: Vector2) -> float:
	var current_height = terrain.height_data[grid_pos].y
	var max_diff = 0.0
	
	for dx in [-1, 0, 1]:
		for dz in [-1, 0, 1]:
			if dx == 0 and dz == 0:
				continue
			var neighbor = grid_pos + Vector2(dx, dz)
			if terrain.height_data.has(neighbor):
				var diff = abs(current_height - terrain.height_data[neighbor].y)
				max_diff = max(max_diff, diff)
	return max_diff
