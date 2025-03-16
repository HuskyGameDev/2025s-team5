@tool
extends Node3D
class_name Terrain3D

var GSA = GroundScatteringAlgorithm.new()
var rng = RandomNumberGenerator.new()

# Terrain size
const xsize = 256
const zsize = 256

# Material for the terrain mesh
var ground_material = preload("res://Objects/Terrain3D/terrain_material.tres")

@onready var terrain_mesh : MeshInstance3D = $TerrainMesh

# Heightmap configuration
@export var heightMap : NoiseTexture2D = preload("res://Objects/Terrain3D/terrain_noise2D.tres")
@export var snowHeightMap : NoiseTexture2D = preload("res://Objects/Terrain3D/snow_noise2D.tres")
var heightImage : Image
var snowHeightImage : Image

# This dictionary will store the vertex positions after height adjustments
var height_data = {}
var snow_height_data = {}

# Reference to the erosion module
var erosion : Erosion

# Terrain color thresholds
const sand_height = 3  # Height threshold for sand
const steep_slope_threshold = 1.5  # Height difference for rocky terrain
@export var max_slope_factor = 1.5  # Factor to control steep slope coloration blending
@export var grass_color = Color(0.6, 0.9, 0.1, 1)  # Grass green (used for blending)
@export var sand_color = Color(0.8, 0.7, 0.5, 1)  # Sandy color

# Interpolation blending control parameters
const height_blend_factor = 3  # Control how much height influences blending
@export var slope_blend_factor = 0.5   # Control how much slope influences blending

# Decimation parameters: these control how aggressively the grid is decimated.
const decim_min_step : int = 1
const decim_max_step : int = 2

func _ready():
	rng.randomize()
	
	# Initialize the height image from the NoiseTexture2D
	heightImage = heightMap.get_image().duplicate()
	snowHeightImage = snowHeightMap.get_image()
	# Create an instance of the Erosion class (make sure erosion.gd is in the specified path)
	erosion = preload("res://Objects/Terrain3D/errosion.gd").new()
	
	# Optionally you could apply erosion here
	# erosion.initialize_erosion_brush_indices(xsize + 1, erosion.erosion_radius)
	# erosion.apply_erosion(heightImage, xsize + 1)
	
	generate_height_data() 	# Generate height data from the height image
	generate_terrain_mesh()	# Generate the decimated low-poly terrain mesh
	generate_snow_mesh()	# Generate the snow terrain layer
	
	# Final setup: add collision and scatter objects if not in the editor
	if not Engine.is_editor_hint():
		terrain_mesh.create_trimesh_collision()
		GSA.terrain = self
		place_ground_scatter()


func generate_height_data() -> void:
	height_data.clear()
	snow_height_data.clear()
	for x in range(xsize + 1):
		for z in range(zsize + 1):
			var raw_height = heightImage.get_pixel(x, z).r
			var adjusted_height = raw_height * 15
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
			
			# Process first triangle (v1, v2, v3)
			# Calculate triangle properties
			var tri1_heights = [v1.y, v2.y, v3.y]
			var max_slope_tri1 = max(
				abs(tri1_heights[0] - tri1_heights[1]),
				abs(tri1_heights[1] - tri1_heights[2]),
				abs(tri1_heights[2] - tri1_heights[0])
			)
			var avg_height_tri1 = (tri1_heights[0] + tri1_heights[1] + tri1_heights[2]) / 3.0
			
			# Determine color for first triangle
			var base_color_tri1 : Color
			if avg_height_tri1 < sand_height:
				base_color_tri1 = sand_color
			else:
				base_color_tri1 = grass_color
			
			# Blend color based on height
			var height_factor_tri1 = clamp((avg_height_tri1 - sand_height) / height_blend_factor, 0.0, 1.0)
			var final_color_tri1 = sand_color.lerp(grass_color, height_factor_tri1)
			
			# Add first triangle to mesh
			add_triangle(st, final_color_tri1, v1, v2, v3)
			
			# Process second triangle (v1, v3, v4)
			var tri2_heights = [v1.y, v3.y, v4.y]
			var max_slope_tri2 = max(
				abs(tri2_heights[0] - tri2_heights[1]),
				abs(tri2_heights[1] - tri2_heights[2]),
				abs(tri2_heights[2] - tri2_heights[0])
			)
			var avg_height_tri2 = (tri2_heights[0] + tri2_heights[1] + tri2_heights[2]) / 3.0
			
			# Determine color for second triangle
			var base_color_tri2 : Color
			if avg_height_tri2 < sand_height:
				base_color_tri2 = sand_color
			else:
				base_color_tri2 = grass_color
			
			# Blend color based on height
			var height_factor_tri2 = clamp((avg_height_tri2 - sand_height) / height_blend_factor, 0.0, 1.0)
			var final_color_tri2 = sand_color.lerp(grass_color, height_factor_tri2)
			
			# Add second triangle to mesh
			add_triangle(st, final_color_tri2, v1, v3, v4)
	
	var mesh = st.commit()
	terrain_mesh.mesh = mesh
	terrain_mesh.set_surface_override_material(0, ground_material)
	#terrain_mesh.position.x -= xsize/2
	#terrain_mesh.position.z -= zsize/2

func generate_snow_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var index_mode = true
	# Turn pixels of the image into quads with vertex color from image
	for x in xsize:
		for z in zsize:
			var color : Color = Color(0.9,0.9,0.9,1)
			
			if index_mode == true:
				st.set_color(color)
				st.set_uv(Vector2(x,z))
				st.add_vertex(Vector3(x,height_data[Vector2(x,z)].y + snow_height_data[Vector2(x,z)].y,z))
				
			else:
				st.set_color(color)
				st.add_vertex(height_data[Vector2(x,z)])
				st.set_color(color)
				st.add_vertex(height_data[Vector2(x+1,z+1)])
				st.set_color(color)
				st.add_vertex(height_data[Vector2(x,z+1)])
				
				st.set_color(color)
				st.add_vertex(height_data[Vector2(x,z)])
				st.set_color(color)
				st.add_vertex(height_data[Vector2(x+1,z)])
				st.set_color(color)
				st.add_vertex(height_data[Vector2(x+1,z+1)])
				
	if index_mode == true:
		for x in xsize-1:
			for z in zsize-1:
				st.add_index((x) * zsize + z)
				st.add_index((x + 1) * zsize + z + 1)
				st.add_index((x) * zsize + z + 1)
				
				st.add_index((x) * zsize + z)
				st.add_index((x + 1) * zsize + z)
				st.add_index((x + 1) * zsize + z + 1)
			
			
	# Generate normals
	st.generate_normals()
	# Build the mesh and set it as the MeshInstance3D's mesh. Then set the material to the terrain material
	var mesh = st.commit()
	$SnowMesh.mesh = mesh
	#$SnowMesh.set_surface_override_material(0,ground_material)
	# The terrain material has "Use vertex color as albedo" enabled
	

# New helper function to add a single colored triangle
func add_triangle(surface_tool, color, a, b, c) -> void:
	var normal = ((b - a).cross(c - a)).normalized()
	normal = -normal  # Flip normal if needed
	surface_tool.set_color(color)
	surface_tool.set_normal(normal)
	surface_tool.add_vertex(a)
	surface_tool.add_vertex(b)
	surface_tool.add_vertex(c)




## Configuration
@export var min_tree_distance: float = 5.0
@export var min_bush_distance: float = 3.0
@export var flower_border_width: int = 2
@export var forest_radius_range: Vector2 = Vector2(20.0, 30.0)
@export var bush_radius_range: Vector2 = Vector2(15.0,25.0)

# Global variables for tracking positions
var bush_positions = []
var occupied_positions = {}  # Dictionary: grid position (Vector2) -> true


#var trees = [preload("res://Art/Models/Vegetation/MidTree.blend"), preload("res://Art/Models/Vegetation/ShortPalm.blend"), preload("res://Art/Models/Vegetation/TallPalm.blend")]
var trees = [preload("res://Objects/GroundScatter/mid_palm.tscn"), preload("res://Objects/GroundScatter/short_palm.tscn"), preload("res://Objects/GroundScatter/tall_palm.tscn")]
var ferns = [preload("res://Objects/GroundScatter/fern.tscn")]
var bushes = [preload("res://Objects/GroundScatter/bush.tscn"), preload("res://Objects/GroundScatter/fern.tscn")]
var flowers = [preload("res://Objects/GroundScatter/flower.tscn")]
var enemy = [preload("res://Objects/Enemy/enemy.tscn")]

func place_ground_scatter() -> void:
	GSA.spawn_plants(trees, 1.0, ferns, 0.40,[], 0.0, Vector2(100,180),forest_radius_range,min_tree_distance, 50,15, false)
#
	GSA.spawn_plants(bushes, 1.0, [], 0.0, [], 0.0, Vector2(70,120),bush_radius_range, min_bush_distance, 40, 20, false)
	GSA.spawn_plants(bushes, 1.0, [], 0.0, flowers, 0.3, Vector2(70,120),bush_radius_range,  min_bush_distance, 40, 20, false)
	GSA.spawn_plants(trees, 0.3, ferns, 0.3, flowers, 0.1, Vector2(20,30),Vector2(0,10),min_tree_distance,15,40,true)
	#
	GSA.spawn_plants(bushes,0.8,flowers,0.3,[],0.0,Vector2(10,15),Vector2(0.0,8.0), min_bush_distance,20, 100, true)
	#
	#GSA.spawn_plants(flowers,0.5,[],0.0,[],0.0,Vector2(50,100),Vector2(3,5),1.0,10,100,false)
	#GSA.spawn_plants(enemy,0.1,[],0.0,[],0.0,Vector2(1,1),Vector2(1,1),10,10,50,true)
