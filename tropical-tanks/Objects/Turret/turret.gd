@tool
extends Node3D

var target_position : Vector3 = Vector3(0,0,0)

var BARREL = preload("res://Objects/Turret/barrel.tscn")

# The node that holds aim_target_position to aim the turret
@export var aimer : Node3D

var split_barrels : int = 1
var double_barrels : int = 2

var shoot_cooldown = 1.0

var angular_spread_per_split_barrel = .2
var position_spread_per_split_barrel = .3 / split_barrels
var double_barrels_radius = .06 + double_barrels * 0.01


@onready var bearing = $TurretHub/Bearing

var split_barrel_holder = []

func _ready() -> void:
	$Timer.wait_time = shoot_cooldown / double_barrels
	
	
	for i in split_barrels:
		var double_barrel_holder = []
		for w in double_barrels:
			var barrel : Barrel = BARREL.instantiate()
			barrel.position.x += - position_spread_per_split_barrel * split_barrels  + position_spread_per_split_barrel * (i + 0.5) * 2
			#barrel.position.x += - double_barrels_radius * double_barrels + double_barrels_radius * (w + 0.5) * 2
			
			if double_barrels > 1:
				var angle = deg_to_rad(360/double_barrels)
				var two_barrel_shift = int(double_barrels == 2) * deg_to_rad(90)
				barrel.position += Vector3(0,double_barrels_radius,0).rotated(Vector3(0,0,1), angle * (w) + two_barrel_shift)
	
				

			
			barrel.rotation.y = angular_spread_per_split_barrel * split_barrels - angular_spread_per_split_barrel * (i + 0.5) * 2
			bearing.add_child(barrel)
		
			double_barrel_holder.append(barrel)
		split_barrel_holder.append(double_barrel_holder)
		
	

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# Change target position if aimer has aim_target_position
	if "aim_target_position" in aimer:
		target_position = aimer.aim_target_position + Vector3(0,.1,0)
	look_at(target_position)
	$TurretHub.global_position = global_position
	rotation.x = clamp(rotation.x, -0.4, 2)
	$TurretHub.rotation = rotation * Vector3(0,1,0)
	bearing.rotation = rotation * Vector3(1,0,1)
	
	


var i = 0
func _on_timer_timeout() -> void:
	for split_barrel in split_barrel_holder:
		split_barrel[i].fire_shell()
		i += 1
		i = i % double_barrels
