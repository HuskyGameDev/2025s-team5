extends Marker3D
class_name TurretMount

const TURRET = preload("res://Components/Turret/turret.tscn")

var has_turret : bool = false:
	set(value):
		has_turret = value
		set_turret()
		
var turret : Turret

func set_turret():
	if turret:
		turret.queue_free()
	if has_turret:
		turret = TURRET.instantiate()
		get_parent().add_child(turret)
		turret.position = position
