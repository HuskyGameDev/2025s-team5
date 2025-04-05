extends Node3D
class_name Barrel

var turret : Turret
var SHELL = preload("res://Components/Shell/shell.tscn")

var shell_spread = 0.01

func _ready() -> void:
	pass

func fire_shell():
	if $RayCast3D.is_colliding():
		return	
	$AudioStreamPlayer3D.play(randf_range(0.0,0.01))
	var shell : Shell = SHELL.instantiate()
	shell.shell_parameters = turret.shell_parameters.duplicate()
	shell.velocity = (turret.initial_shot_power / turret.shell_parameters.mass) * -global_basis.z.normalized()#.rotated(global_basis.x.normalized(),randf_range(0,shell_spread)).rotated(global_basis.z.normalized(),randf_range(0,2*PI))
	shell.rotation = global_rotation
	shell.position = %ShellSpawn.global_position
	shell.parent_body = turret.get_parent()
	get_tree().root.add_child(shell)
