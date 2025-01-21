extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


@onready var chassis = %PhysicalTankChassis
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction = false
	if Input.is_action_pressed("ui_up"):
		direction = true
		velocity = chassis.basis.z * SPEED * Vector3(1,0,1)
		
	if Input.is_action_pressed("ui_down"):
		direction = true
		velocity = chassis.basis.z * -SPEED * Vector3(1,0,1)
	
	if Input.is_action_pressed("ui_left"):
		chassis.apply_torque(Vector3(0,SPEED, 0))
	if Input.is_action_pressed("ui_right"):
		chassis.apply_torque(Vector3(0,-SPEED, 0))
		
	if !direction:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
