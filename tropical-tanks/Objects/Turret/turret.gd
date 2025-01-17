extends Node3D

var SHELL = preload("res://Objects/Shell/shell.tscn")

var target_position : Vector3 = Vector3(0,0,0)

# The node that holds aim_target_position to aim the turret
@export var aimer : Node3D

func _process(delta: float) -> void:
	pass


func fire_shell():
	print("Fired Shell!")
	var shell : Shell = SHELL.instantiate()
	shell.velocity = $TurretHub/Bearing/MeshInstance3D.global_basis.z * -100
	shell.rotation = $TurretHub/Bearing/MeshInstance3D.global_rotation
	shell.position = global_position + Vector3(0,1,0)
	get_tree().root.add_child(shell)
	

func _physics_process(delta: float) -> void:
	# Change target position if aimer has aim_target_position
	if "aim_target_position" in aimer:
		target_position = aimer.aim_target_position + Vector3(0,.1,0)
	look_at(target_position)
	$TurretHub.global_position = global_position
	rotation.x = clamp(rotation.x, -0.4, 2)
	$TurretHub.rotation = rotation * Vector3(0,1,0)
	$TurretHub/Bearing.rotation = rotation * Vector3(1,0,1)
	
	


func _on_timer_timeout() -> void:
	fire_shell()
