extends Node3D
class_name HealthManager

@export var health : float = 100.0

func take_damage(attack : Attack):
	health = health - attack.damage
	
	if health <= 0:
		death()

func death():
	var P = get_parent()
	if P.has_method("death"):
		P.death()
	else:
		get_parent().queue_free()
