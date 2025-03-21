extends Resource
class_name GroundScatter

@export_group("Objects")

@export var primary_objects : Array[PackedScene] 
@export_range(0.0,1.0,0.01) var primary_probability : float = 1.0

@export var secondary_objects : Array[PackedScene]
@export_range(0.0,1.0,0.01) var secondary_probability : float = 1.0

@export var tertiary_objects : Array[PackedScene]
@export_range(0.0,1.0,0.01) var tertiary_probability : float = 1.0

@export_group("Placement Parameters")
@export var spawn_on_grid : bool = false
@export_subgroup("Cluster")
@export var amount_of_clusters : int = 1
@export var minimum_cluster_spacing : float
@export var cluster_radius : float
@export_subgroup("Object")
@export var object_count_range : Vector2i = Vector2i(1,1)
@export var minimum_object_spacing : float

# GENERALIZED object PLACEMENT FUNCTION
var terrain : Terrain3D

func spawn(T : Terrain3D):
	terrain = T
	var centers = [] # Holds positions of the center of object groups
	var clusters = [] # Holds clusters of primary_objects
	
	# Pick center generation algorithm
	if spawn_on_grid: 
		var temp_centers = []
		for x in range(0, terrain.xsize, minimum_cluster_spacing):
			for z in range(0, terrain.zsize, minimum_cluster_spacing):
				temp_centers.append(Vector2(x, z))
		for i in clampi(amount_of_clusters,0,temp_centers.size()):
			var pop_center = temp_centers.pop_at(randi_range( 0 , temp_centers.size()-1 ))
			centers.append(pop_center)
			
	else: # Get random centers on map
		centers = poisson_disk_sampling(minimum_cluster_spacing,amount_of_clusters)
	
	print(centers.size())
				
	
	for center in centers:
		var object_count : int = randi_range(int(object_count_range.x), int(object_count_range.y))
		var placed_primary_objects = []
		
		for i in range(object_count):
			var angle = randf() * TAU #Random angle in radians
			var distance = randf_range(0, cluster_radius)
			var pos = center + Vector2(cos(angle), sin(angle)) * distance
			var grid_pos = get_grid_position(pos)
			
			# Forest Spawning
			if is_position_valid(grid_pos) and !is_too_close(grid_pos, placed_primary_objects, minimum_object_spacing) and randf() < primary_probability:
				var object = primary_objects.pick_random()
				place_object(object, grid_pos, true)
				placed_primary_objects.append(grid_pos)
				
				# secondary_object spawning
				if secondary_objects.size() > 0 and randf() < secondary_probability:
					var secondary_object_pos = grid_pos + Vector2(randf_range(-1, 1), randf_range(-1, 1))
					secondary_object_pos = get_grid_position(secondary_object_pos)
					if is_position_valid(secondary_object_pos):
						var secondary_object = secondary_objects.pick_random()
						place_object(secondary_object, secondary_object_pos, true)
						
		clusters.append(placed_primary_objects)
	
	# tertiary_object Border
	if tertiary_objects.size() > 0:
		for cluster in clusters:
			var edge_positions = []
			
			# Determine edge positions for each bush cluster
			for secondary_pos in cluster:
				for dx in [-1, 0, 1]:
					for dz in [-1, 0, 1]:
						if dx == 0 and dz == 0:
							continue
						var neighbor_pos = secondary_pos + Vector2(dx, dz)
						if !cluster.has(neighbor_pos) and is_position_valid(neighbor_pos):
							edge_positions.append(neighbor_pos)
			
			# Place tertiary_objects along the border edges
			for edge_pos in edge_positions:
				if randf() < tertiary_probability and is_position_valid(edge_pos):
					var tertiary_object = tertiary_objects.pick_random()
					place_object(tertiary_object, edge_pos, false)

########################################
# FUNCTION: Poisson Disk Sampling
########################################
func poisson_disk_sampling(min_spacing : float, count : int) -> Array:
	var points = []
	var attempts = 0
	
	while points.size() < count and attempts < count * count:
		var new_point = Vector2(randf_range(0, terrain.xsize), randf_range(0, terrain.zsize))
		var valid = true
		for existing_point in points:
			if new_point.distance_to(existing_point) < min_spacing:
				valid = false
				break
		if valid:
			points.append(new_point)
		attempts += 1
	print(attempts)
	return points
	
	
func place_object(scene_pack: PackedScene, grid_pos: Vector2, random_rotation: bool) -> void:
	var world_pos = terrain.height_data[grid_pos]
	var object = scene_pack.instantiate()
	object.position = world_pos 
	if random_rotation:
		object.rotation.y = (randf() * TAU) 
	terrain.terrain_mesh.add_child(object)
	terrain.occupied_positions[grid_pos] = true
	
func get_grid_position(pos: Vector2) -> Vector2:
	return Vector2(clamp(roundi(pos.x), 0, terrain.xsize), clamp(roundi(pos.y), 0, terrain.zsize))
	
func is_position_valid(grid_pos: Vector2) -> bool:
	var valid = false
	if !terrain.height_data.has(grid_pos):
		return false
	var h = terrain.height_data[grid_pos].y
	var slope = calculate_slope(grid_pos)
	if slope < terrain.steep_slope_threshold and h > terrain.sand_height:
		valid = true
		
	if terrain.snow_height_data[grid_pos].y > 0:
		return false
	return valid
		
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
