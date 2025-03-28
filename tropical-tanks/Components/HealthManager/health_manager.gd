extends Node3D
class_name HealthManager

@export var max_health : float = 100.0
@export var death_effects : Array[Resource]
@export var take_water_damage : bool = false

var health = max_health
func take_damage(attack : Attack):
	if health > 0:
		
		
		health = health - attack.damage
		if take_water_damage:
			health = health - attack.water_depth
		
		if health <= 0:
			death()



func death():
	for death_effect in death_effects:
		if death_effect and death_effect.has_method("trigger_effect"):
			death_effect.trigger_effect(self)
	
	var P = get_parent()
	if P.has_method("death"):
		P.death()
		health = max_health
	else:
		get_parent().queue_free()
