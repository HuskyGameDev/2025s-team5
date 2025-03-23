extends Node3D

# Initialize the raycast
@onready var ray = $RayCast3D

# Mesh to show on the ground where the RayCast3D intersects the ground
@onready var visual : MeshInstance2D = $MeshInstance2D

# Default white reticle: you are aiming at and can hit the ground here
var reticle : CompressedTexture2D = preload("res://Art/Images/CrossHairALLWHITE.svg")
# Yellow reticle: this target is in range but the bullet will hit an object on the way
var blocked_reticle = preload("res://Art/Images/CrossHairBlocked.svg")
# Red reticle: the bullet cannot reach this space, move closer!
var outOfRange_reticle : CompressedTexture2D = preload("res://Art/Images/CrossHairOutOfRange.svg")

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Load 
	visual.texture = reticle

# Called every frame. 'delta' is the time elapsed between each frame
func _physics_process(delta: float) -> void:
	if reachable() and in_range():
		# Use a 
		if targeting() :
			visual.texture = reticle # TODO: set the image to be a different reticle that shows you are targeting an enemy
		else :
			visual.texture = reticle
	elif !in_range():
		visual.texture = outOfRange_reticle
	else :
		visual.texture = blocked_reticle
	
	if ray.is_colliding() :
		var target : Vector3 = ray.get_collision_point()
	
	# POSITION CONTROL
	
	if Input.is_action_pressed("ui_up") :
		$".".position += 3

# Is the reticle hovering over an enemy
func targeting() -> bool :
	# TODO: write code for this function
	return true

# Checks to see if the selected position is blocked by an object or not
# Basically, will the shot hit where the reticle is aiming
func reachable() -> bool :
	# TODO: write code for this function
	return true

# Checks if the bullet can reach the space
func in_range() -> bool :
	# TODO: write code for this function
	return true
