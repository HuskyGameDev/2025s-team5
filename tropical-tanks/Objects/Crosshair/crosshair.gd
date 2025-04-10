extends Node3D

@export var crosshair_speed = 17
@export var camera : TopdownCamera
@export var local_aiming : bool = true ## To place the aiming reticule in local tank coordinates

@onready var ray = $RayCast3D
@onready var visual = $Node3D

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Load 
	#visual.texture = reticle
	pass

# Called every frame. 'delta' is the time elapsed between each frame
func _physics_process(delta: float) -> void:
	if(local_aiming and camera.target_node):
		global_position = camera.target_node.global_position
		
	if camera.mouse_mode:
		ray.global_position = camera.aim_target_position + Vector3(0,50,0)
	else:
		camera.aim_target_position = ray.get_collision_point()
		
	if(ray.is_colliding()):
		visual.global_position = ray.get_collision_point()
		
	if Input.is_action_pressed("3d_crosshair_up"):
		ray.position += Vector3(0, 0, -1) * delta * crosshair_speed
		
	if Input.is_action_pressed("3d_crosshair_left"):
		ray.position += Vector3(-1, 0, 0) * delta * crosshair_speed
		
	if Input.is_action_pressed("3d_crosshair_down"):
		ray.position += Vector3(0, 0, 1) * delta * crosshair_speed
		
	if Input.is_action_pressed("3d_crosshair_right"):
		ray.position += Vector3(1, 0, 0) * delta * crosshair_speed

	$Node3D/Sprite3D.rotation.y += delta
# Is the reticle hovering over an enemy
func targeting() -> bool :
	if(ray.is_colliding()):
		if(ray.get_collider() == CollisionObject3D):
			return true
		else:
			return false
	return false
