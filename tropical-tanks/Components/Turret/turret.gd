@tool
extends Node3D

signal change_crosshair(crosshair_index)

var target_position : Vector3 = Vector3(0,0,0)

var BARREL = preload("res://Components/Turret/barrel.tscn")

# The node that holds aim_target_position to aim the turret
@export var aimer : Node3D

@export var crosshair_setter : CrosshairSetter

@export var split_barrels : int = 1 :
	set(value):
		split_barrels = value
		if Engine.is_editor_hint():
			set_barrels()
		
@export var double_barrels : int = 1 :
	set(value):
		double_barrels = value
		if Engine.is_editor_hint():
			set_barrels()

var shoot_cooldown = 1.0


@onready var bearing = $TurretHub/Bearing
@onready var aim_laser = %AimLaser

var split_barrel_holder = []

func _ready() -> void:
	set_barrels()
	
	
	
	
func set_barrels() -> void:
	if !bearing:
		return
	var angular_spread_per_split_barrel = .2
	var position_spread_per_split_barrel = .3 / split_barrels
	var double_barrels_radius = .06 + double_barrels * 0.01
	
	for child in bearing.get_children():
		if child is Barrel:
			child.queue_free()
	
	split_barrel_holder = []
	$Timer.wait_time = shoot_cooldown / double_barrels
	
	
	for i_split_barrel in split_barrels:
		var double_barrel_holder = []
		for i_double_barrel in double_barrels:
			var barrel : Barrel = BARREL.instantiate()
			barrel.position.x += - position_spread_per_split_barrel * split_barrels  + position_spread_per_split_barrel * (i_split_barrel + 0.5) * 2
			#barrel.position.x += - double_barrels_radius * double_barrels + double_barrels_radius * (w + 0.5) * 2
			
			if double_barrels > 1:
				var angle = deg_to_rad(360/double_barrels)
				var two_barrel_shift = int(double_barrels == 2) * deg_to_rad(90)
				barrel.position += Vector3(0,double_barrels_radius,0).rotated(Vector3(0,0,1), angle * (i_double_barrel) + two_barrel_shift)
	
				

			
			barrel.rotation.y = angular_spread_per_split_barrel * split_barrels - angular_spread_per_split_barrel * (i_split_barrel + 0.5) * 2
			bearing.add_child(barrel)
		
			double_barrel_holder.append(barrel)
		split_barrel_holder.append(double_barrel_holder)
		
	
var look_position = Vector3.ZERO
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# Change target position if aimer has aim_target_position
	if "aim_target_position" in aimer:
		global_position.distance_to(aimer.aim_target_position)
		target_position = aimer.aim_target_position + Vector3(0,1.0,0)
		change_crosshair.emit(0)
		crosshair_setter.set_crosshair(0)
		look_position = look_position.move_toward(target_position,delta * 30)
		if aim_laser.is_colliding():
			if target_position.length() - aim_laser.get_collision_point().length() > 0:
				change_crosshair.emit(1)
				crosshair_setter.set_crosshair(1)
			else:
				change_crosshair.emit(0)
				crosshair_setter.set_crosshair(0)
	look_at(target_position)
	$TurretHub.global_position = global_position
	rotation.x = clamp(rotation.x, -0.4, 2)
	$TurretHub.global_rotation = global_rotation * Vector3(0,1,0)
	bearing.rotation = rotation * Vector3(1,0,1)
	look_at(look_position)
	
	#$TurretHub.global_position = global_position
	#rotation.x = clamp(rotation.x, -0.4, 2)
	#$TurretHub.global_rotation = global_rotation * Vector3(1,1,1)
	#bearing.rotation = rotation * Vector3(1,0,1)
	
	


var i = 0
func _on_timer_timeout() -> void:
	for split_barrel in split_barrel_holder:
		split_barrel[i].fire_shell()
		i += 1
		i = i % double_barrels
