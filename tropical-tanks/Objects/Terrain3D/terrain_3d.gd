@tool
extends Node3D
class_name Terrain3D

var erosion : Erosion = Erosion.new()
var rng = RandomNumberGenerator.new()
var color_noise = FastNoiseLite.new()

# Terrain size
@export_subgroup("Terrain Size")
@export var xsize = 256
@export var zsize = 256

# Heightmap configuration
@export_group("Height Maps")
@export var heightMap : NoiseTexture2D = preload("res://Objects/Terrain3D/terrain_noise2D.tres")
@export var snowHeightMap : NoiseTexture2D = preload("res://Objects/Terrain3D/snow_noise2D.tres")

var heightImage : Image
var snowHeightImage : Image
var colorImage : Image = Image.new()

# This dictionary will store the vertex positions after height adjustments
var height_data = {}
var snow_height_data = {}


@export_group("Ground Scatter")
@export var ground_scatters : Array[GroundScatter]

# Material for the terrain mesh
var ground_material = preload("res://Objects/Terrain3D/terrain_material.tres")

@onready var terrain_mesh : MeshInstance3D = $TerrainMesh
@onready var snow_mesh : MeshInstance3D = $SnowMesh
func _ready():
	rng.randomize()
	color_noise.seed = rng.seed
	erosion.erosion_seed = rng.seed
	
	# Initialize the height image from the NoiseTexture2D
	heightImage = heightMap.get_image()
	snowHeightImage = snowHeightMap.get_image()
	colorImage.load("res://Art/Images/cat.jpg");
	
	var precomputed_erosion_height_map = erosion.load("res://Objects/Terrain3D/HeightMaps/eroded_map.png")
	if precomputed_erosion_height_map:
		heightImage = precomputed_erosion_height_map
	else:
		erosion.initialize_erosion_brush_indices(xsize + 1, erosion.erosion_radius)
		erosion.apply_erosion(heightImage, xsize + 1)
		erosion.save(heightImage, "res://Objects/Terrain3D/HeightMaps/eroded_map.png")
	
	generate_height_data() 	# Generate height data from the height image
	calculate_colors()		# Calculate the colors
	generate_terrain_mesh()	# Generate the decimated low-poly terrain mesh
	generate_snow_mesh()	# Generate the snow terrain layer
	
	# Final setup: add collision and scatter objects if not in the editor
	if not Engine.is_editor_hint():
		terrain_mesh.create_trimesh_collision()
		place_ground_scatter()


func generate_height_data() -> void:
	height_data.clear()
	snow_height_data.clear()
	
	# First pass: populate height data
	for x in range(xsize + 1):
		for z in range(zsize + 1):
			var raw_height = heightImage.get_pixel(x, z).r
			var adjusted_height = raw_height * 30 - 2.5
			height_data[Vector2(x, z)] = Vector3(
				x + randf_range(-0.2, 0.0),
				adjusted_height,
				z + randf_range(-0.2, 0.0)
			)
			snow_height_data[Vector2(x, z)] = Vector3(
				x + randf_range(-0.2, 0.0),
				(snowHeightImage.get_pixel(x,z).r - 0.5) * 3,
				z + randf_range(-0.2, 0.0)
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
	colorImage = Image.create(xsize + 1, zsize + 1, false, Image.FORMAT_RGBA8)
	for x in range(xsize + 1):
		for z in range(zsize + 1):
			var adjusted_height = height_data[Vector2(x, z)].y
			
			# Calculate maximum slope difference
			var max_slope_diff = 0.0
			for dx in [-1, 1]:
				var nx = x + dx
				if nx >= 0 and nx <= xsize:
					var neighbor_height = height_data[Vector2(nx, z)].y
					max_slope_diff = max(max_slope_diff, abs(adjusted_height - neighbor_height))
			for dz in [-1, 1]:
				var nz = z + dz
				if nz >= 0 and nz <= zsize:
					var neighbor_height = height_data[Vector2(x, nz)].y
					max_slope_diff = max(max_slope_diff, abs(adjusted_height - neighbor_height))
			
			# Calculate color components
			var slope_blend = clamp(max_slope_diff / steep_slope_threshold * max_slope_factor, 0.0, 1.0)
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

# Helper function to generate decimated indices along one axis with some natural variation.
func generate_decimated_indices(max_index: int, min_step: int, max_step: int) -> Array:
	var indices = [0]
	var current = 0
	while current < max_index:
		var step = rng.randi_range(min_step, max_step)
		current += step
		if current >= max_index:
			indices.append(max_index)
			break
		else:
			indices.append(current)
	return indices


# Decimation parameters: these control how aggressively the grid is decimated.
const decim_min_step : int = 1
const decim_max_step : int = 2
func generate_terrain_mesh() -> void:
	# Generate decimated indices for both axes. This irregular grid will control our lower poly resolution.
	var decim_x = generate_decimated_indices(xsize, decim_min_step, decim_max_step)
	var decim_z = generate_decimated_indices(zsize, decim_min_step, decim_max_step)
	
	# Build a 2D array of decimated vertices.
	# For each cell defined by consecutive indices, average the high-res height data and add a slight jitter.
	var decimated_vertices = []
	for i in range(decim_x.size() - 1):
		var row = []
		for j in range(decim_z.size() - 1):
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
			var v1 = decimated_vertices[i][j]
			var v2 = decimated_vertices[i+1][j]
			var v3 = decimated_vertices[i+1][j+1]
			var v4 = decimated_vertices[i][j+1]
			
			
			var image_color_1 = (colorImage.get_pixel(v1.x, v1.z) + colorImage.get_pixel(v2.x, v2.z) + colorImage.get_pixel(v3.x, v3.z)) / 3.
			
			add_triangle(st, image_color_1, v1, v2, v3)
			
			var image_color_2 = (colorImage.get_pixel(v1.x, v1.z) + colorImage.get_pixel(v3.x, v3.z) + colorImage.get_pixel(v4.x, v4.z)) / 3.
			
			# Add second triangle to mesh
			add_triangle(st, image_color_2, v1, v3, v4)
	
	var mesh = st.commit()
	terrain_mesh.mesh = mesh
	terrain_mesh.set_surface_override_material(0, ground_material)
	terrain_mesh.position.x = -xsize/2.0
	terrain_mesh.position.z = -zsize/2.0
	
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
