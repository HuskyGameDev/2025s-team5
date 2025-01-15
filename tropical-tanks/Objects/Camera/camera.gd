extends Node3D

@export var follow_speed : float = 2.0
@export var mouse_weight : float = 0.01

@onready var camera = %Camera3D


func _physics_process(delta: float) -> void:
	# Get mouse position relative to the center of the viewport
	# Scale it down by mouse_weight
	var mouse_position = (get_viewport().get_mouse_position() -  Vector2(get_viewport().size / 2) ) * mouse_weight
	
	# find target position by adding moouse position to the camera root global position
	var cam_target_position = global_position + Vector3(mouse_position.x, 0, mouse_position.y)
	
	# Move camera towards target position
	%Camera3D.position += (cam_target_position - %Camera3D.global_position) * delta * follow_speed * Vector3(1,0,1)
	
