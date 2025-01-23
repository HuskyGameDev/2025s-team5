extends VehicleBody3D

var SPEED = 70
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	%BackWheelRight.engine_force = 0
	%FrontWheelRight.engine_force = 0
	%BackWheelRight.engine_force = 0
	%FrontWheelRight.engine_force = 0
	var left_drive_direction = 0
	var right_drive_direction = 0
	if Input.is_action_pressed("ui_up"):
		left_drive_direction = 1
		right_drive_direction = 1

		
	if Input.is_action_pressed("ui_down"):
		left_drive_direction = -1
		right_drive_direction = -1
	
	if Input.is_action_pressed("ui_left"):
		left_drive_direction = left_drive_direction * -1
		right_drive_direction = 2
		
	if Input.is_action_pressed("ui_right"):
		left_drive_direction = 2
		right_drive_direction = right_drive_direction * -1
		
		
	%BackWheelRight.engine_force = SPEED * right_drive_direction
	%BackWheelRight2.engine_force = SPEED * right_drive_direction
	%FrontWheelRight.engine_force = SPEED * right_drive_direction
	
	%BackWheelLeft.engine_force = SPEED * left_drive_direction
	%BackWheelLeft2.engine_force = SPEED * left_drive_direction
	%FrontWheelLeft.engine_force = SPEED * left_drive_direction
