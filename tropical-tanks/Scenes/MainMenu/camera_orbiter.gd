@tool
extends Camera3D

@export var height : float = 30.0 :
	set(value):
		position.y = value
		height = value
@export var time = 0
@export var radius = 50
@export var seconds_per_loop = 8


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RayCast3D.target_position = Vector3(radius,0,0)
		
	
func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		position = Vector3(radius * cos(time),height, radius * sin(time))
		time += delta / seconds_per_loop
		
		if Input.is_action_just_pressed("scroll_up"):
			height += 1
		
		if Input.is_action_just_pressed("scroll_down"):
			height -= 1
	#var speed
	#speed = 5
	#position.x += speed*delta
	#
	#if (position.x >= 75):
		#position.x = 0
