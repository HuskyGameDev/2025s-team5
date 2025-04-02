extends Node3D

@export var tank : TankChassis
@export var turrets : Array[Turret]
@export var target : Node3D


var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false,
	"shoot" = false
}

var targeting = false
func _physics_process(delta: float) -> void:
	if tank:
		tank.controls = controls
		if turrets and target:
			for turret in turrets:
				turret.target_position = target.get_child(0).global_position
	else:
		queue_free()
	
	if targeting == false:
		#print(tank.global_transform.basis.z)
		var angle = (-tank.global_transform.basis.z).signed_angle_to((target.get_child(0).global_position - tank.global_position) * Vector3(1,0,1), Vector3(0,1,0))
		#print(rad_to_deg(angle))
		if angle > 0.3:
			controls["turn_right"] = false
			controls["turn_left"] = true
		elif angle < -0.3:
			controls["turn_right"] = true
			controls["turn_left"] = false
		else:
			controls["turn_right"] = false
			controls["turn_left"] = false
			controls["forward"] = true


	
func _on_timer_timeout() -> void:
	if (randi_range(0,2)) == 0:
		controls["forward"] = true
	if (randi_range(0,8)) == 0:
		controls["forward"] = false
	if (randi_range(0,10)) == 0:
		controls["forward"] = true
	if (randi_range(0,4)) == 0:
		controls["forward"] = false
	var r = randi_range(2, 4)
	if (r == 2):
		controls["turn_right"] = false
		controls["turn_left"] = true
	if (r == 3):
		controls["turn_left"] = false
		controls["turn_right"] = true
	if (r == 4):
		controls["turn_right"] = false
		controls["turn_left"] = false
		
	if randi_range(0, 3) == 0:
		controls["shoot"] = true
	else:
		controls["shoot"] = false
	if global_position.distance_to(target.global_position) > 10:
		targeting = true
	else: 
		targeting = false
