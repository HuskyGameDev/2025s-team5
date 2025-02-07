extends CharacterBody3D
class_name Tank

const SPEED = 250.0

var move_vector = Vector3(0,0,-1)

@export var tank_rotation : float = 0.0

@onready var ray = $RayCast3D

var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false,
	"shoot" = false,
	
}

func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	var move_normal = Vector3(0,1,0)
	move_vector = Vector3(0,0,-1).rotated(move_normal,tank_rotation)
	
	if ray and ray.is_colliding():
		velocity = Vector3(0,0,0)
		
		
		var rotation_axis = (move_normal.cross(ray.get_collision_normal())).normalized()
		var move_vector_angle = move_normal.angle_to(ray.get_collision_normal())
		
		if controls.get("shoot"):
			for turret in get_children():
				if turret is Turret:
					turret.shoot()
		
		if controls.get("forward"):
			velocity = delta * SPEED * move_vector
		if controls.get("backward"):
			velocity = delta * -SPEED * move_vector
		
		if controls.get("turn_left"):
			tank_rotation += SPEED / 180 * delta
		if controls.get("turn_right"):
			tank_rotation += -SPEED / 180 * delta
		
		if move_vector_angle != 0 and velocity != Vector3.ZERO:
			velocity = velocity.rotated(rotation_axis,move_vector_angle)
			
		
	else:
		velocity += get_gravity() * delta
	$tank.look_at($tank.global_position + move_vector)
	move_and_slide()
