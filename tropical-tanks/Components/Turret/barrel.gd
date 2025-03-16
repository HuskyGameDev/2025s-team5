extends Node3D
class_name Barrel

var turret : Turret
var SHELL = preload("res://Objects/Shell/shell.tscn")

var shell_spread = 0.01

func _ready() -> void:
	pass

func fire_shell():
	if $RayCast3D.is_colliding():
		return	
	print("Fired Shell!")
	var shell : Shell = SHELL.instantiate()
	shell.shell_parameters = turret.shell_parameters
	shell.velocity = -20 * global_basis.z.normalized().rotated(global_basis.x,randf_range(0,shell_spread)).rotated(global_basis.z,randf_range(0,2*PI))
	shell.rotation = global_rotation
	shell.position = %ShellSpawn.global_position
	get_tree().root.add_child(shell)
