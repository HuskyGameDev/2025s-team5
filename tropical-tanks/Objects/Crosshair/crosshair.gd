extends Node3D

# Initialize the raycast
@onready var ray = $RayCast3D

# Mesh to show on the ground where the RayCast3D intersects the ground
@onready var visual : MeshInstance3D = $MeshInstance3D

# Default white reticle: you are aiming at and can hit the ground here
var reticle : CompressedTexture2D = preload("res://Art/Images/CrossHairALLWHITE.svg")
# Red reticle: aiming at an enemy
var enemy_aim : CompressedTexture2D = preload("res://Art/Images/CrossHairOutOfRange.svg")

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Load 
	visual.texture = reticle

# Called every frame. 'delta' is the time elapsed between each frame
func _physics_process(delta: float) -> void:
	if(ray.is_colliding()):
		visual.global_position = ray.get_collision_point()
	if(targeting):
		visual.texture = enemy_aim
	else:
		visual.texture = reticle
	
	if Input.is_action_pressed("3d_crosshair_up"):
		position += Vector3(5, 0, 0)
		
	if Input.is_action_pressed("3d_crosshair_left"):
		position += Vector3(0, 0, -5)
		
	if Input.is_action_pressed("3d_crosshair_down"):
		position += Vector3(-5, 0, 0)
		
	if Input.is_action_pressed("3d_crosshair_right"):
		position += Vector3(0, 0, 5)

# Is the reticle hovering over an enemy
func targeting() -> bool :
	if(ray.is_colliding()):
		if(ray.get_collider() == CollisionObject3D):
			return true
		else:
			return false
	return false
