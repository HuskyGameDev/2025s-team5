extends CharacterBody3D


const SPEED = 250.0
const JUMP_VELOCITY = 4.5

var move_vector = Vector3(0,0,1)

var tank_rotation = 0.0
@onready var ray = %RayCast3D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if ray.is_colliding():
		velocity = Vector3(0,0,0)
		
		var move_normal = Vector3(0,1,0)
		
		move_vector = Vector3(0,0,1).rotated(move_normal,tank_rotation)
		
		
		
		var difference = move_normal - ray.get_collision_normal()
		var rotation_axis = (move_normal.cross(ray.get_collision_normal())).normalized()
		var move_vector_angle = move_normal.angle_to(ray.get_collision_normal())
		
		
		
		if Input.is_action_pressed("ui_up"):
			velocity = move_vector.rotated(rotation_axis,move_vector_angle) * SPEED * delta
		
		if Input.is_action_pressed("ui_down"):
			velocity = move_vector.rotated(rotation_axis,move_vector_angle) * -SPEED * delta
		
		if Input.is_action_pressed("ui_left"):
			tank_rotation += SPEED / 180 * delta
		if Input.is_action_pressed("ui_right"):
			tank_rotation += -SPEED / 180 * delta
		
		$tank.look_at($tank.global_position + move_vector.rotated(rotation_axis,move_vector_angle))
		
	else:
		velocity += get_gravity() * delta
		
	move_and_slide()
