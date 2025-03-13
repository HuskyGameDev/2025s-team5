@tool
extends Node3D

# Terrain size
@export var xsize = 100
@export var zsize = 100

# Material for the terrain mesh
var ground_material = preload("res://Objects/Terrain3D/terrain_material.tres")

# Heightmap configuration
@export var heightMap : NoiseTexture2D = preload("res://Objects/Terrain3D/terrain_noise2D.tres")
var heightImage : Image


# This dictionary will store the vertex positions after height adjustments
var height_data = {}

# Reference to the erosion module
var erosion : Erosion

# Terrain color thresholds
const sand_height = 3  # Height threshold for sand
const steep_slope_threshold = 1.5  # Height difference for rocky terrain
@export var max_slope_factor = 1.5  # Factor to control steep slope coloration blending
@export var grass_color = Color(0.6, 0.9, 0.1, 1)  # Grass green (used for blending)

# Color parameters for blending
@export var sand_color = Color(0.8, 0.7, 0.5, 1)  # Sandy color
const rock_color = Color(0.5, 0.3, 0.1, 1)  # Rocky (brown) color

# Interpolation blending control parameters
@export var height_blend_factor = 3  # Control how much height influences blending
@export var slope_blend_factor = 0.5   # Control how much slope influences blending

func _ready():
	heightMap = ResourceLoader.load("res://Objects/Terrain3D/terrain_noise2D.tres") as NoiseTexture2D
	# Initialize the height image from the NoiseTexture2D
	heightImage = heightMap.get_image().duplicate()
	
	# Create an instance of the Erosion class (make sure erosion.gd is in the specified path)
	erosion = preload("res://Objects/Terrain3D/errosion.gd").new()
	
	# Precompute erosion brush indices and weights
	#erosion.initialize_erosion_brush_indices(xsize + 1, erosion.erosion_radius)
	
	# Apply erosion to modify the height image
	#erosion.apply_erosion(heightImage, xsize + 1)
	
	# Generate height data from the height image
	generate_height_data()
	
	# Generate the terrain mesh
	generate_terrain_mesh()
	
	# Final setup: add collision and scatter objects if not in the editor
	if not Engine.is_editor_hint():
		$MeshInstance3D.create_trimesh_collision()
		place_ground_scatter()

func generate_height_data() -> void:
	height_data.clear()
	for x in range(xsize + 1):
		for z in range(zsize + 1):
			var raw_height = heightImage.get_pixel(x, z).r
			var adjusted_height = raw_height * 15
			height_data[Vector2(x, z)] = Vector3(
				x + randf_range(-0.2, 0.0),
				adjusted_height,
				z + randf_range(-0.2, 0.0)
			)

func generate_terrain_mesh() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for x in range(xsize):
		for z in range(zsize):
			# Get height values
			var h1 = height_data[Vector2(x, z)].y
			var h2 = height_data[Vector2(x + 1, z)].y
			var h3 = height_data[Vector2(x + 1, z + 1)].y
			var h4 = height_data[Vector2(x, z + 1)].y
			
			# Compute slope
			var max_slope = max(abs(h1 - h2), abs(h2 - h3), abs(h3 - h4), abs(h4 - h1))
			
			# Determine base color based on height and slope
			var base_color
			if max_slope > steep_slope_threshold:
				base_color = rock_color  # Rocky (brown) color for steep slopes
			elif h1 < sand_height:
				base_color = sand_color  # Sandy color for low areas
			else:
				base_color = grass_color  # Grass color for higher areas

			# Blend colors based on height using interpolation control
			var height_factor = clamp((h1 - sand_height) / height_blend_factor, 0.0, 1.0)
			var height_blend = sand_color.lerp(grass_color, height_factor)
			
			# Adjust the color blending based on the slope
			#var slope_factor = clamp((max_slope - steep_slope_threshold) / (max_slope_threshold - steep_slope_threshold), 0.0, 1.0)
			#var final_color = base_color.lerp(height_blend, slope_factor)

			# Add quad with the determined color
			add_quad(st, height_blend, 
				height_data[Vector2(x, z)],
				height_data[Vector2(x + 1, z)],
				height_data[Vector2(x + 1, z + 1)],
				height_data[Vector2(x, z + 1)]
			)

	st.generate_normals()
	var mesh = st.commit()
	$MeshInstance3D.mesh = mesh
	$MeshInstance3D.set_surface_override_material(0, ground_material)

func add_quad(surface_tool, color, a, b, c, d) -> void:
	surface_tool.set_color(color)
	surface_tool.add_vertex(a)
	surface_tool.add_vertex(b)
	surface_tool.add_vertex(c)
	
	surface_tool.set_color(color)
	surface_tool.add_vertex(a)
	surface_tool.add_vertex(c)
	surface_tool.add_vertex(d)


# Vegetation assets
var GROUND_SCATTER = preload("res://Objects/GroundScatter/TallPalm.blend")
var GROUND_SCATTER2 = preload("res://Objects/GroundScatter/ShortPalm.blend")
var GROUND_SCATTER3 = preload("res://Objects/GroundScatter/MidTree.blend")
var GROUND_SCATTER4 = preload("res://Objects/GroundScatter/BushyPlant.blend")
var GROUND_SCATTER5 = preload("res://Objects/GroundScatter/RedFlower.blend")
var GROUND_SCATTER6 = preload("res://Objects/GroundScatter/BlueFlower.blend")
var GROUND_SCATTER7 = preload("res://Objects/GroundScatter/fern.blend")
var GROUND_SCATTER8 = preload("res://Objects/GroundScatter/PurpleFlower.blend")


## Configuration
@export var min_tree_distance: float = 5.0
@export var min_bush_distance: float = 3.0
@export var flower_border_width: int = 2
@export var forest_min_radius: float = 20.0
@export var forest_max_radius: float = 30.0
@export var bush_max_density: float = 0.2  # Lower chance for bushes.
@export var fern_max_density: float = 0.05  # Lower chance for ferns.

# Global variables for tracking positions
var bush_positions = []
var occupied_positions = {}  # Dictionary: grid position (Vector2) -> true

func place_ground_scatter() -> void:
	spawn_forests()
	spawn_bushlands()
	spawn_flower_borders()
	spawn_palm_forests()

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

########################################
# FUNCTION: Spawn Forests
########################################
func spawn_forests() -> void:
	var forest_centers = poisson_disk_sampling(40.0, 60.0, 15)
	
	for center in forest_centers:
		var forest_radius = randf_range(forest_min_radius, forest_max_radius)
		var tree_count = randi() % 80 + 100
		var placed_trees = []
		
		# Spawn trees in the forest cluster
		for i in range(tree_count):
			var angle = randf() * TAU
			var distance = randf_range(0, forest_radius)
			var pos = center + Vector2(cos(angle), sin(angle)) * distance
			var grid_pos = get_grid_position(pos)
			
			if is_position_valid(grid_pos) and !is_too_close(grid_pos, placed_trees, min_tree_distance):
				var tree = select_forest_tree().instantiate()
				place_plant(tree, grid_pos, true)
				placed_trees.append(grid_pos)
				
				# Occasionally spawn a fern under a tree (15% chance)
				if randf() > 0.85:
					var fern_pos = grid_pos + Vector2(randf_range(-1, 1), randf_range(-1, 1))
					fern_pos = get_grid_position(fern_pos)
					if is_position_valid(fern_pos):
						var fern = GROUND_SCATTER7.instantiate()
						place_plant(fern, fern_pos, true)
						
########################################
# FUNCTION: Spawn Bushlands
########################################
func spawn_bushlands() -> Array:
	var bushland_centers = poisson_disk_sampling(30.0, 50.0, 20)
	var bush_clusters = []
	
	for center in bushland_centers:
		var bush_radius = randf_range(15.0, 25.0)
		var plant_count = randi() % 50 + 70  # Total plants (bushes + ferns)
		var placed_bushes = []
		var placed_ferns = []
		var d_plants = []  # Tracks all plants (bushes & ferns)

		for i in range(plant_count):
			var angle = randf() * TAU
			var distance = randf_range(0, bush_radius)
			var pos = center + Vector2(cos(angle), sin(angle)) * distance
			var grid_pos = get_grid_position(pos)

			if is_position_valid(grid_pos) and !is_too_close(grid_pos, d_plants, min_bush_distance):
				if randf() > 0.5:  # 50/50 chance for bush or fern
					var bush = GROUND_SCATTER4.instantiate()
					place_plant(bush, grid_pos, true)
					placed_bushes.append(grid_pos)
				else:
					var fern = GROUND_SCATTER7.instantiate()
					place_plant(fern, grid_pos, true)
					placed_ferns.append(grid_pos)

				d_plants.append(grid_pos)  # Track both bushes & ferns
		
		bush_clusters.append(placed_bushes)
	
	return bush_clusters



########################################
# FUNCTION: Spawn Flower Borders
########################################
func spawn_flower_borders() -> void:
	var bush_clusters = spawn_bushlands()
	
	for cluster in bush_clusters:
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
			if randf() > 0.7 and is_position_valid(edge_pos):
				var flower = select_flower().instantiate()
				place_plant(flower, edge_pos, false)

########################################
# FUNCTION: Spawn Palm Forests
########################################
func spawn_palm_forests() -> void:
	# Iterate over a grid of sample positions in the terrain.
	for x in range(0, xsize, 15):
		for z in range(0, zsize, 15):
			var grid_pos = Vector2(x, z)
			if is_position_valid(grid_pos):
				var height = height_data.get(grid_pos, Vector3.ZERO).y
				if height < sand_height + 2 and height > sand_height - 1:
					if randf() > 0.7:
						spawn_palm_cluster(grid_pos)

########################################
# FUNCTION: Spawn a Palm Cluster
########################################
func spawn_palm_cluster(center: Vector2) -> void:
	var palm_count = randi() % 15 + 20
	var placed_palms = []
	
	for i in range(palm_count):
		var angle = randf() * TAU
		var distance = randf_range(0, 8.0)
		var pos = center + Vector2(cos(angle), sin(angle)) * distance
		var grid_pos = get_grid_position(pos)
		
		if is_position_valid(grid_pos) and !is_too_close(grid_pos, placed_palms, min_tree_distance):
			var palm = select_palm_tree().instantiate()
			place_plant(palm, grid_pos, true)
			placed_palms.append(grid_pos)

########################################
# HELPER FUNCTIONS
########################################
func get_grid_position(pos: Vector2) -> Vector2:
	return Vector2(clamp(roundi(pos.x), 0, xsize), clamp(roundi(pos.y), 0, zsize))

func is_position_valid(grid_pos: Vector2) -> bool:
	if not height_data.has(grid_pos):
		return false
	
	var h = height_data[grid_pos].y
	var slope = calculate_slope(grid_pos)
	
	return slope < steep_slope_threshold and h > sand_height

func calculate_slope(grid_pos: Vector2) -> float:
	var current_height = height_data[grid_pos].y
	var max_diff = 0.0
	
	for dx in [-1, 0, 1]:
		for dz in [-1, 0, 1]:
			if dx == 0 and dz == 0:
				continue
			var neighbor = grid_pos + Vector2(dx, dz)
			if height_data.has(neighbor):
				var diff = abs(current_height - height_data[neighbor].y)
				max_diff = max(max_diff, diff)
	return max_diff

func place_plant(plant: Node3D, grid_pos: Vector2, random_rotation: bool) -> void:
	var world_pos = height_data[grid_pos]
	plant.position = world_pos
	plant.rotation.y = (randf() * TAU) if random_rotation else 0
	add_child(plant)
	occupied_positions[grid_pos] = true

func select_forest_tree() -> Resource:
	return [GROUND_SCATTER, GROUND_SCATTER2, GROUND_SCATTER3].pick_random()

func select_flower() -> Resource:
	return [GROUND_SCATTER5, GROUND_SCATTER6, GROUND_SCATTER8].pick_random()

func select_palm_tree() -> Resource:
	return [GROUND_SCATTER, GROUND_SCATTER2].pick_random()

func is_too_close(pos: Vector2, existing: Array, min_dist: float) -> bool:
	for p in existing:
		if pos.distance_to(p) < min_dist:
			return true
	return false
