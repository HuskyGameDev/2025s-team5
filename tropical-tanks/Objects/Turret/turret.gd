extends Node3D

var target_position : Vector3 = Vector3(0,0,0)

# The node that holds aim_target_position to aim the turret
@export var aimer : Node3D

func _physics_process(delta: float) -> void:
	# Change target position if aimer has aim_target_position
	if "aim_target_position" in aimer:
		target_position = aimer.aim_target_position
	look_at(target_position)
