# THIS IS A TOOL AND WILL RUN INSIDE THE EDITOR TO VISUALIZE THE TERRAIN
@tool
extends Node3D

# Size in pixels to render of the image
@export var xsize = 100
@export var zsize = 100

# Load heightMap and convert to image
@onready var heightMap = preload("res://Objects/Terrain3D/terrain_noise2D.tres")
@onready var heightImage = heightMap.get_image()

func _ready():
	# Create a dictionary with Vector2 keys to each pixel's color
	var height_data = {}
	for x in xsize:
		for z in zsize:
			height_data[Vector2(x,z)] = heightImage.get_pixel(x,z).r * 10
	
	# Start surface tool with PRIMITIVE_TRIANGLES
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Turn pixels of the image into quads with vertex color from image
	for x in xsize:
		for z in zsize:
			var color : Color = heightImage.get_pixel(x,z) * Color(0,1,0,1)
			
			#st.set_normal(Vector3(0,1,0))
			st.set_color(color)
			st.add_vertex(Vector3(x + randf_range(-0.3,0.3)    , height_data[Vector2(x,z)], z   + randf_range(-0.3,0.3)  ))
			
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
	$MeshInstance3D.set_surface_override_material(0,preload("res://Objects/Terrain3D/terrain_material.tres"))
	# The terrain material has "Use vertex color as albedo" enabled
	
	# Stop following code if still in editor
	if Engine.is_editor_hint():
		return
		
	# Generate a collision shape for the mesh
	$MeshInstance3D.create_trimesh_collision()
