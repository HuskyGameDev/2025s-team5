extends CharacterBody3D
class_name TankChassis

const SPEED = 250.0

var move_vector = Vector3(0,0,-1)

@export var tank_rotation : float = 0.0

@onready var ground_raycast = $GroundRaycast
@onready var tank_chassis = $TankChassisModelParts

var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false,
	"shoot" = false,
	
}

func _physics_process(delta: float) -> void:
	ground_raycast.global_position = global_position
	# Add the gravity.
	
	var move_normal = Vector3(0,1,0)
	move_vector = Vector3(0,0,-1).rotated(move_normal,tank_rotation)
	
	if ground_raycast.is_colliding():
		velocity = Vector3.ZERO #velocity.move_toward(Vector3.ZERO,delta * 25)
	

		#position += ground_raycast.get_collision_point() - ground_raycast.global_position - ground_raycast.target_position
		
		
		var rotation_axis = (move_normal.cross(ground_raycast.get_collision_normal())).normalized()
		var move_vector_angle = move_normal.angle_to(ground_raycast.get_collision_normal())
		
		if controls.get("forward"):
			velocity = (delta * SPEED * move_vector)
			if move_vector_angle != 0 and velocity != Vector3.ZERO:
				velocity = velocity.rotated(rotation_axis,move_vector_angle)
		if controls.get("backward"):
			velocity = (delta * -SPEED * move_vector).rotated(rotation_axis.normalized(),move_vector_angle)
			if move_vector_angle != 0 and velocity != Vector3.ZERO:
				velocity = velocity.rotated(rotation_axis, -move_vector_angle)

		if controls.get("turn_left"):
			tank_rotation += SPEED / 180 * delta
		if controls.get("turn_right"):
			tank_rotation += -SPEED / 180 * delta
	
		
		#if move_vector_angle != 0 and velocity != Vector3.ZERO:
		#	velocity = velocity.rotated(rotation_axis,move_vector_angle)
			#look_at(global_position + move_vector.rotated(rotation_axis,move_vector_angle))
			#tank_chassis.look_at(global_position + move_vector.rotated(rotation_axis,move_vector_angle))
			
	elif !is_on_floor():
		velocity += get_gravity() * delta
		
	if controls.get("shoot"):
			for turret in get_children():
				if turret is Turret:
					turret.shoot()
	look_at(global_position + move_vector)
	move_and_slide()
