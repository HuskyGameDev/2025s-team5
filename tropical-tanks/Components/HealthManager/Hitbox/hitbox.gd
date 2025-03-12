extends Area3D
class_name Hitbox

@export var health_manager : HealthManager 

func _ready() -> void:
	assert(health_manager, "ERROR: health_manager must be set in hitbox inspector.")

func take_damage(attack : Attack):
	health_manager.take_damage(attack)
