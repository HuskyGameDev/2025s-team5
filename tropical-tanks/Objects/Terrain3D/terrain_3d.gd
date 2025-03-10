# THIS IS A TOOL AND WILL RUN INSIDE THE EDITOR TO VISUALIZE THE TERRAIN
@tool
extends Node3D

# Size in pixels to render of the image
@export var xsize = 100
@export var zsize = 100

var ground_material = preload("res://Objects/Terrain3D/terrain_material.tres")

# Load heightMap and convert to images
@export var heightMap : NoiseTexture2D
#@export var heightMap = preload("res://Objects/Terrain3D/terrain_noise2D.tres")
@onready var heightImage = heightMap.get_image()

var height_data = {}
var water_level = 0.4 #Float: -1 for no water, 0.0 to 1.0 for water level

var index_mode : bool = false

func _ready():
	# Create a dictionary with Vector2 keys to each pixel's red color multplied by 10
	for x in xsize + 1:
		for z in zsize + 1:
			height_data[Vector2(x,z)] = Vector3(x + randf_range(-0.2,0.2), (heightImage.get_pixel(x,z).r - water_level) * 10, z   + randf_range(-0.2,0.2))
	
	# Start surface tool with PRIMITIVE_TRIANGLES
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Turn pixels of the image into quads with vertex color from image
	for x in xsize:
		for z in zsize:
			var color : Color = heightImage.get_pixel(x,z) * Color(0.6,0.9,0.1,1)
			
			if index_mode == true:
				st.set_color(color)
				st.set_uv(Vector2(x,z))
				st.add_vertex(height_data[Vector2(x,z)])
				
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
			
			
			
			#st.set_color(color)
			#st.add_vertex(Vector3(x    , height_data[Vector2(x,z)], z    ))
			#st.set_color(color)
			#st.add_vertex(Vector3(x + 1, height_data[Vector2(x+1,z+1)], z + 1))
			#st.set_color(color)
			#st.add_vertex(Vector3(x    , height_data[Vector2(x,z+1)], z + 1))
			#
			#st.set_color(color)
			#st.add_vertex(Vector3(x    , height_data[Vector2(x,z)], z    ))
			#st.set_color(color)
			#st.add_vertex(Vector3(x + 1, height_data[Vector2(x+1,z)], z    ))
			#st.set_color(color)
			#st.add_vertex(Vector3(x + 1, height_data[Vector2(x+1,z+1)], z + 1))
			
	# Generate normals
	st.generate_normals()
	# Build the mesh and set it as the MeshInstance3D's mesh. Then set the material to the terrain material
	var mesh = st.commit()
	$MeshInstance3D.mesh = mesh
	$MeshInstance3D.set_surface_override_material(0,ground_material)
	# The terrain material has "Use vertex color as albedo" enabled
	
	# Stop following code if still in editor
	if Engine.is_editor_hint():
		return
		
	# Generate a collision shape for the mesh
	$MeshInstance3D.create_trimesh_collision()
	place_ground_scatter()
	
var GROUND_SCATTER = preload("res://Objects/GroundScatter/groundScatter.tscn")
func place_ground_scatter():
	for i in randi_range(30,60):
		var ground_scatter_object = GROUND_SCATTER.instantiate()
		add_child(ground_scatter_object)
		var pos = Vector2(randi_range(0,xsize-1),randi_range(0,zsize-1))
		ground_scatter_object.position = height_data[pos]
		
	
