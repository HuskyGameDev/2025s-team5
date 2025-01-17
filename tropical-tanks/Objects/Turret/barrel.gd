extends Node3D
class_name Barrel

var SHELL = preload("res://Objects/Shell/shell.tscn")

var shell_spread = 0.1



func fire_shell():
	print("Fired Shell!")
	var shell : Shell = SHELL.instantiate()
	shell.velocity = -20 * global_basis.z.rotated(global_basis.x,randf_range(0,shell_spread)).rotated(global_basis.z,randf_range(0,2*PI))
	shell.rotation = global_rotation
	shell.position = %ShellSpawn.global_position
	get_tree().root.add_child(shell)
