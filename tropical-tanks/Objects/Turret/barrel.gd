extends Node3D
class_name Barrel

var SHELL = preload("res://Objects/Shell/shell.tscn")

func fire_shell():
	print("Fired Shell!")
	var shell : Shell = SHELL.instantiate()
	shell.velocity = global_basis.z * -30
	shell.rotation = global_rotation
	shell.position = global_position + Vector3(0,1,0)
	get_tree().root.add_child(shell)
