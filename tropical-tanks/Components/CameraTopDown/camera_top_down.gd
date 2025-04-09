extends Node3D
class_name TopdownCamera

@export var follow_speed : float = 2.0
@export var mouse_weight : float = 0.01

var turrets : Array[Turret]

@export var target_node : Node3D

@export var mouse_mode = false

@onready var camera = %Camera3D
@export var crosshair_setter : CrosshairSetter

var aim_target_position : Vector3 
var camera_offset = Vector3(0,20,0)

var ray_length = 200 # How far the mouse detects the ground

func _ready() -> void:
	if target_node is TankChassis:
		turrets = target_node.get_turrets()
	assert(turrets.size() > 0, "Camera controller has no turrets to control") # ADD TURRETS TO THE CAMERA IN INSPECTOR
	
	
func _physics_process(delta: float) -> void:
	if target_node:
		camera_offset = Vector3(0,1,0) * target_node.view_range
		position = target_node.position
	# Use a raycast from mouse to find where the mouse is intersecting the scene.
	if(mouse_mode):
		aim_target_position = raycast_from_mouse(get_viewport().get_mouse_position(),1)["position"]
			
	if turrets:
		for turret in turrets:
			if turret:
				turret.target_position = aim_target_position
			
		#change_crosshair.emit(0)
		#crosshair_setter.set_crosshair(0)
		#if aim_laser.is_colliding():
			#var collision_difference = (aim_laser.get_collision_point() - global_position).length() - (target_position - global_position).length()
			#print(collision_difference)
			#if collision_difference + 1 < 0:
				#change_crosshair.emit(1)
				#crosshair_setter.set_crosshair(1)
	
	# Find target position by adding mouse position to the camera root global position
	# Then add camera offset
	var cam_target_position = \
		global_position  \
		+ (aim_target_position - global_position) * Vector3(1,0,1) / 2.1 \
		+ camera_offset
	
	# Move camera towards target position
	%Camera3D.position += (cam_target_position - %Camera3D.global_position) * delta * follow_speed * Vector3(1,1,1)
	
	
	
	
func shake(_force):
	pass


func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = camera.project_ray_origin(m_pos)
	var ray_end = ray_start + camera.project_ray_normal(m_pos) * ray_length
	var world3d : World3D = get_world_3d()
	var space_state = world3d.direct_space_state
	
	if space_state == null:
		return
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)
