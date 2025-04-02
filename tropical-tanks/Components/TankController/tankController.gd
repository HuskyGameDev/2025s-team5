extends Node3D

@export var tank : TankChassis
@export var turrets : Array[Turret]
@export var target : Node3D
@export var targeting_accuracy : float = 0.5

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
	
	if targeting == true:
		#print(tank.global_transform.basis.z)
		var angle = (-tank.global_transform.basis.z).signed_angle_to((target.get_child(0).global_position - tank.global_position) * Vector3(1,0,1), Vector3(0,1,0))
		#print(rad_to_deg(angle))
		if angle > targeting_accuracy:
			controls["turn_right"] = false
			controls["turn_left"] = true
		elif angle < -targeting_accuracy:
			controls["turn_right"] = true
			controls["turn_left"] = false
		else:
			controls["turn_right"] = false
			controls["turn_left"] = false
			controls["forward"] = true


	
func _on_timer_timeout() -> void:
	var distance_to_target = tank.global_position.distance_to(target.get_child(0).global_position)
	if (randf() < 0.2):
		controls["forward"] = true
	match(randi_range(1, 3)):
		1:
			controls["turn_right"] = false
			controls["turn_left"] = true
		2:
			controls["turn_left"] = false
			controls["turn_right"] = true
		3:
			controls["turn_right"] = false
			controls["turn_left"] = false
		
	if (randf() < 0.3) and distance_to_target < 30:
		controls["shoot"] = true
	else:
		controls["shoot"] = false
		
	print(distance_to_target, "m away")
	if distance_to_target > 30:
		targeting = true
	else: 
		targeting = false
	#print("Targeting Player = ", targeting)
