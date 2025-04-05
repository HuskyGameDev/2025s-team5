@tool
extends Node3D
class_name Terrain3D

var rng = RandomNumberGenerator.new()
var color_noise = FastNoiseLite.new()

# Terrain size


# Heightmap configuration
@export_group("Size")
@export var xsize = 256 ## X Size of terrain3D in vertices.
@export var zsize = 256 ## Z Size of terrain3D in vertices.
@export_group("Terrain Parameters")
@export var hill_height : float = 30.0 ## The height to stretch hills vertically.
@export var water_level : float = 2.5 ## The height to shift terrain down and fill with water.
@export var water_shallow_depth : float = 0.0 ## The max depth that is safe for a body. Bodies deeper than this value will take damage.
@export var heightMap : NoiseTexture2D ## The height map to be used when generating terrain.
@export_subgroup("Decimation")
@export var decimateTerrain = true ## If [code]true[/code] the terrain will be decimated based on the decimation step.
@export var decimation_step_range : Vector2i = Vector2i(1,3) ## A range to randomly pick how many indices to step over each decimation step
@export_subgroup("Erosion")
@export var erosion : Erosion ## The erosion module. Leave empty for no erosion.
@export_group("Snow Parameters")
@export var snow_coverage : float = 0.5 ## The percent of the map to be covered in snow
@export var snow_depth : float = 3.0 ## The depth of the deepest snow
@export var snowHeightMap : NoiseTexture2D ## The heightmap for snow generation

@export_category("Color")
@export_group("Color Settings")
@export var terrainColoringMode : terrainColoringOptions = terrainColoringOptions.randomTriangle
@export_group("Colors")
@export var terrain_colors : Array[Color] = [Color(Color.GREEN)]
@export var beach_colors : Array[Color] = [Color(Color.YELLOW)]
@export var slope_colors : Array[Color] = [Color(Color.BROWN)]
@export var snowbase_colors : Array[Color] = [Color(Color.BLACK)]
enum terrainColoringOptions {
	averageTriangle, ## Averages the coloring per triangle
	randomTriangle, ## Picks a random vertex of a triangle color to use
	averageSquare, ## Average the coloring per square 
	randomSquare ## Pickes a random vertex of a square color to use
}

@export_category("Ground Scatter")
@export_group("Ground Scatter")
@export var editor_show_ground_scatter : bool = false
@export var ground_scatters : Array[GroundScatter] ## The objects placed on the terrain. Ordered first to last from top to bottom.

@onready var terrain_mesh : MeshInstance3D = $TerrainMesh
@onready var snow_mesh : MeshInstance3D = $SnowMesh
@onready var water_mesh : WaterMesh = $WaterMesh
@onready var heightImage : Image
@onready var snowHeightImage : Image
@onready var colorImage : Image

# This dictionary will store the vertex positions after height adjustments
var height_data = {}
var snow_height_data = {}

# Material for the terrain mesh
var ground_material = preload("res://Objects/Terrain3D/terrain_material.tres")

func _ready():
	await get_tree().process_frame
	
	rng.randomize()
	color_noise.seed = rng.seed
	
	# Initialize the height image from the NoiseTexture2D
	heightImage = heightMap.get_image()
	heightImage.resize(xsize,zsize)
	snowHeightImage = Image.create_empty(xsize,zsize,false,Image.Format.FORMAT_RGBA8)
	colorImage = preload("res://Art/Images/DebugTexture.png").get_image()
	
	if erosion: check_erosion()		# Check for erosiong map / do erosion 
	generate_terrain_height_data() 	# Generate height data from the height image
	if snowHeightMap: snowHeightImage = snowHeightMap.get_image()
	snowHeightImage.resize(xsize,zsize)
	generate_snow_height_data()
	generate_snow_mesh()
	calculate_colors()		# Calculate the colors
	generate_terrain_mesh()	# Generate the decimated low-poly terrain mesh
	
	place_ground_scatter()
	# Final setup: add collision and scatter objects if not in the editor
	if not Engine.is_editor_hint():
		terrain_mesh.create_trimesh_collision()
		$BoundingWalls/StaticBody3D/negZ.position.z = -zsize/2
		$BoundingWalls/StaticBody3D/posZ.position.z = zsize/2
		$BoundingWalls/StaticBody3D/negX.position.x = -xsize/2
		$BoundingWalls/StaticBody3D/posX.position.x = xsize/2
		
		
		
		water_mesh.shallow_depth = water_shallow_depth
		place_ground_scatter()

func check_erosion() -> void:
	erosion.erosion_seed = rng.seed
	var precomputed_erosion_height_map = erosion.load("res://Objects/Terrain3D/HeightMaps/eroded_map.png")
	if precomputed_erosion_height_map:
		heightImage = precomputed_erosion_height_map
	else:
		erosion.initialize_erosion_brush_indices(xsize + 1, erosion.erosion_radius)
		erosion.apply_erosion(heightImage, xsize + 1)
		erosion.save(heightImage, "res://Objects/Terrain3D/HeightMaps/eroded_map.png")

func generate_terrain_height_data() -> void:
	height_data.clear()
	if water_level > 0:
		water_mesh.show()
	else:
		water_mesh.hide()
	for x in range(xsize):
		for z in range(zsize):
			var raw_terrain_height = heightImage.get_pixel(x, z).r
			var adjusted_terrain_height = raw_terrain_height * hill_height - water_level
			height_data[Vector2(x, z)] = Vector3(
				x + randf_range(-0.2, 0.2),
				adjusted_terrain_height,
				z + randf_range(-0.2, 0.2)
			)

func generate_snow_height_data() -> void:
	snow_height_data.clear()
	for x in range(xsize):
		for z in range(zsize):
			var raw_snow_height = snowHeightImage.get_pixel(x,z).r
			var adjusted_snow_height = (raw_snow_height - 1.0 + snow_coverage)  * snow_depth
			snow_height_data[Vector2(x, z)] = Vector3(
				x + randf_range(-0.2, 0.2),
				adjusted_snow_height,
				z + randf_range(-0.2, 0.2)
			)
			
# Terrain color thresholds
const sand_height = 3  # Height threshold for sand
const steep_slope_threshold = 1.25  # Height difference for rocky terrain
const max_slope_factor = 1.5  # Factor to control steep slope coloration blending
const grass_color = Color(0.6, 0.9, 0.1, 1)  # Grass green (used for blending)
const sand_color = Color(0.8, 0.7, 0.5, 1)  # Sandy color

# Interpolation blending control parameters
const height_blend_factor = 3  # Control how much height influences blending
const slope_blend_factor = 0.5   # Control how much slope influences blending
func calculate_colors():
	colorImage.resize(xsize, zsize)
	#Image.create(xsize + 1, zsize + 1, false, Image.FORMAT_RGBA8)
	for x in range(xsize):
		for z in range(zsize):
			var adjusted_height = height_data[Vector2(x, z)].y
			
			# Calculate maximum slope difference
			var slope = calculate_slope(x,z)
			
			# Calculate slope components
			var slope_blend = clamp(slope / steep_slope_threshold * max_slope_factor, 0.0, 1.0)
			
			var height_blend = clamp((adjusted_height - sand_height) / height_blend_factor, 0.0, 1.0)
			
			
			# Base color determination
			var base_color: Color
			if adjusted_height < sand_height:
				base_color = sand_color
			else:
				# Generate green variations using noise
				var noise_value = color_noise.get_noise_2d(x * 2, z * 2)
				noise_value = (noise_value + 1.0) / 2.0  # Normalize to 0-1
				
				# Define green palette
				var greens = [
					Color(0.35, 0.55, 0.2),   # Dark forest green
					Color(0.45, 0.7, 0.25),    # Vibrant lime
					Color(0.6, 0.85, 0.3),     # Bright chartreuse
					Color(0.5, 0.65, 0.25)     # Olive green
				]
				
				# Select and blend greens based on noise
				var green_index = clamp(int(noise_value * greens.size()), 0, greens.size() - 1)
				var next_green = greens[clamp(green_index + 1, 0, greens.size() - 1)]
				var green_blend = (noise_value * greens.size()) - green_index
				base_color = greens[green_index].lerp(next_green, green_blend)
				
				# Add subtle yellow variation
				if noise_value > 0.7:
					base_color = base_color.lerp(Color(0.7, 0.8, 0.4), (noise_value - 0.7) * 3)
			
			# Slope-based blending with rocky color
			var rocky_color = Color(0.45, 0.35, 0.25)  # Earthy brown
			var slope_color = base_color.lerp(rocky_color, smoothstep(0.2, 0.8, slope_blend))
			
			# Final color blending
			var final_color = sand_color.lerp(slope_color, height_blend)
			
			# Add micro-variations using original height noise
			var micro_variation = 1.0 + (heightImage.get_pixel(x, z).r - 0.5) * 0.1
			final_color = final_color * Color(micro_variation, micro_variation, micro_variation)

			colorImage.set_pixel(x, z, final_color)
			#colorImage.set_pixel(x, z, Color(1-slope,1-slope ,1-slope,1.0))
			
	#colorImage.save_png("res://Objects/Terrain3D/HeightMaps/color_map.png")



func colors():
	Image.create(xsize, zsize, false, Image.FORMAT_RGBA8)
	for x in range(xsize + 1):
		for z in range(zsize + 1):
			var pixel_height = height_data[Vector2(x, z)].y
			
			var slope = calculate_slope(x,z)
			#colorImage.set_pixel(x, z, Color(slope, slope, slope))
			
func calculate_slope(x, z):
	var height = height_data[Vector2(x, z)].y
	var dx_slope = 0.0
	var dz_slope = 0.0
	
	if x > 0 and x < xsize - 1:
		var height_left = height_data[Vector2(x - 1, z)].y
		var height_right = height_data[Vector2(x + 1, z)].y
		dx_slope = (height_right - height_left) / 2.0
	elif x == 0:
		dx_slope = height_data[Vector2(x + 1, z)].y - height
	elif x == xsize:
		dx_slope = height - height_data[Vector2(x - 1, z)].y
	
	if z > 0 and z < zsize - 1:
		var height_down = height_data[Vector2(x, z - 1)].y
		var height_up = height_data[Vector2(x, z + 1)].y
		dz_slope = (height_up - height_down) / 2.0
	elif z == 0:
		dz_slope = height_data[Vector2(x, z + 1)].y - height
	elif z == zsize:
		dz_slope = height - height_data[Vector2(x, z - 1)].y
	
	return sqrt(dx_slope * dx_slope + dz_slope * dz_slope)
	
func generate_terrain_mesh() -> void:
	# Generate decimated indices for both axes. This irregular grid will control the lower poly resolution.
	var decim_x = generate_decimated_indices(xsize, decimation_step_range)
	var decim_z = generate_decimated_indices(zsize, decimation_step_range)
	
	# Build a 2D array of decimated vertices.
	# For each cell defined by consecutive indices, average the high-res height data and add a slight jitter.
	var decimated_vertices = []
	for i in range(decim_x.size() - 2):
		var row = []
		for j in range(decim_z.size() - 2):
			var x_start = decim_x[i]
			var x_end = decim_x[i + 1]
			var z_start = decim_z[j]
			var z_end = decim_z[j + 1]
			
			# Average vertices from the high-resolution grid in this block.
			var sum = Vector3.ZERO
			var count = 0
			for x in range(x_start, x_end + 1):
				for z in range(z_start, z_end + 1):
					sum += height_data[Vector2(x, z)]
					count += 1
			var avg = sum / count if count > 0 else Vector3((x_start + x_end) / 2.0, 0, (z_start + z_end) / 2.0)

			
			# Apply a small random offset (jitter) based on the size of the block.
			var cell_width = float(x_end - x_start)
			var cell_depth = float(z_end - z_start)
			var jitter_amount_x = cell_width * 0.1
			var jitter_amount_z = cell_depth * 0.1
			avg.x += rng.randf_range(-jitter_amount_x, jitter_amount_x)
			avg.z += rng.randf_range(-jitter_amount_z, jitter_amount_z)
			
			row.append(avg)
		decimated_vertices.append(row)
	
	# Use SurfaceTool to generate the mesh from our decimated (and now irregular) grid.
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# For each quad in the decimated grid, process two triangles separately with individual colors
	for i in range(decimated_vertices.size() - 1):
		for j in range(decimated_vertices[i].size() - 1):
			var vertices = [
				decimated_vertices[i][j],
				decimated_vertices[i+1][j],
				decimated_vertices[i+1][j+1],
				decimated_vertices[i][j+1]
			]
			var v1 = decimated_vertices[i][j]
			var v2 = decimated_vertices[i+1][j]
			var v3 = decimated_vertices[i+1][j+1]
			var v4 = decimated_vertices[i][j+1]
			
			var image_color_1 = Color(0, 0, 0)
			var image_color_2 = Color(0, 0, 0)
			
			match terrainColoringMode:
				terrainColoringOptions.averageTriangle:
					image_color_1 = (colorImage.get_pixel(v1.x, v1.z) + colorImage.get_pixel(v2.x, v2.z) + colorImage.get_pixel(v3.x, v3.z)) / 3.
					image_color_2 = (colorImage.get_pixel(v1.x, v1.z) + colorImage.get_pixel(v3.x, v3.z) + colorImage.get_pixel(v4.x, v4.z)) / 3.
				terrainColoringOptions.randomTriangle:
					var randomVertex1 = [v1, v2, v3].pick_random()
					image_color_1 = (colorImage.get_pixel(randomVertex1.x, randomVertex1.z))
					var randomVertex2 = [v1, v3, v4].pick_random()
					image_color_2 = (colorImage.get_pixel(randomVertex2.x, randomVertex2.z))
				terrainColoringOptions.randomSquare:
					var randomVertex1 = [v1, v2, v3, v4].pick_random()
					image_color_1 = (colorImage.get_pixel(randomVertex1.x, randomVertex1.z))
					image_color_2 = (colorImage.get_pixel(randomVertex1.x, randomVertex1.z))
				terrainColoringOptions.averageSquare:
					image_color_1 = (colorImage.get_pixel(v1.x, v1.z) + colorImage.get_pixel(v2.x, v2.z) + colorImage.get_pixel(v3.x, v3.z) + colorImage.get_pixel(v4.x, v4.z)) / 4.
					image_color_2 = (colorImage.get_pixel(v1.x, v1.z) + colorImage.get_pixel(v2.x, v2.z) + colorImage.get_pixel(v3.x, v3.z) + colorImage.get_pixel(v4.x, v4.z)) / 4.
				
				
			add_triangle(st, image_color_1, v1, v2, v3)
			add_triangle(st, image_color_2, v1, v3, v4)
	
	var mesh = st.commit()
	terrain_mesh.mesh = mesh
	terrain_mesh.set_surface_override_material(0, ground_material)
	terrain_mesh.position.x = -xsize/2.0
	terrain_mesh.position.z = -zsize/2.0

# Helper function to generate decimated indices along one axis with some natural variation.
func generate_decimated_indices(max_index: int, decimation_step_range : Vector2i) -> Array:
	var current_index = 0
	var indices = [current_index]
	
	while current_index < max_index:
		# Select a number of indices to step
		var step_indices = rng.randi_range(decimation_step_range.x, decimation_step_range.y)
		current_index += step_indices # Step that number of indices
		if current_index >= max_index:
			indices.append(max_index)
			break
		else:
			indices.append(current_index)
			
	return indices

# New helper function to add a single colored triangle
func add_triangle(surface_tool, color, a, b, c) -> void:
	var normal = ((b - a).cross(c - a)).normalized()
	normal = -normal  # Flip normal if needed
	surface_tool.set_color(color)
	surface_tool.set_normal(normal)
	surface_tool.add_vertex(a)
	surface_tool.add_vertex(b)
	surface_tool.add_vertex(c)
	
	
func generate_snow_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Turn pixels of the image into quads with vertex color from image
	for x in xsize:
		for z in zsize:
			#var color : Color = Color(0.9,0.9,0.9,1)
			#st.set_color(color)
			
			st.set_uv(Vector2(x,z))
			st.add_vertex(Vector3(x,height_data[Vector2(x,z)].y + snow_height_data[Vector2(x,z)].y,z))
				
	for x in xsize-1:
		for z in zsize-1:
			st.add_index((x) * zsize + z)
			st.add_index((x + 1) * zsize + z + 1)
			st.add_index((x) * zsize + z + 1)
			
			st.add_index((x) * zsize + z)
			st.add_index((x + 1) * zsize + z)
			st.add_index((x + 1) * zsize + z + 1)
			
	st.generate_normals()
	var mesh = st.commit()
	snow_mesh.mesh = mesh
	snow_mesh.position.x = -xsize/2.0
	snow_mesh.position.z = -zsize/2.0


var occupied_positions = {}
func place_ground_scatter() -> void:
	for ground_scatter : GroundScatter in ground_scatters:
		ground_scatter.spawn(self)
	pass
