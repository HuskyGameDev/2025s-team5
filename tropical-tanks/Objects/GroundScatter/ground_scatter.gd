@tool
extends Node3D


@export var is_collidable : bool = false

func death():
	queue_free()

@export var mesh : MeshInstance3D
