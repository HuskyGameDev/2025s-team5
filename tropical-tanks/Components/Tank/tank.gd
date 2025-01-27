extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var move_vector = Vector3(0,0,1)
@onready var ray = %RayCast3D

@onready var chassis = %PhysicalTankChassis
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if ray.is_colliding():
		velocity = Vector3.ZERO
		
		move_vector = move_vector * SPEED
		
		var move_normal = (move_vector * Vector3(1,0,0)).cross( move_vector * Vector3(0,0,1))
		
		
		var difference = move_normal - ray.get_collision_normal()
		var new_normal = move_normal.cross(ray.get_collision_normal())
		var move_vector_angle = move_normal.angle_to(ray.get_collision_normal())
		
		
		
		if Input.is_action_pressed("ui_up"):
			velocity = (move_vector.rotated(new_normal,move_vector_angle)) * SPEED
		if Input.is_action_pressed("ui_down"):
			velocity = (move_vector.rotated(new_normal,move_vector_angle)) * -SPEED
		
		
	else:
		velocity += get_gravity() * delta

	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#
	#var direction = false
	#
	#if Input.is_action_pressed("ui_up"):
		#direction = true
		#velocity = chassis.basis.z * SPEED * Vector3(1,0,1)
		#
	#if Input.is_action_pressed("ui_down"):
		#direction = true
		#velocity = chassis.basis.z * -SPEED * Vector3(1,0,1)
	#
	#if Input.is_action_pressed("ui_left"):
		#chassis.apply_torque(Vector3(0,SPEED, 0))
	#if Input.is_action_pressed("ui_right"):
		#chassis.apply_torque(Vector3(0,-SPEED, 0))
		#
	#if !direction:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
		

	move_and_slide()
