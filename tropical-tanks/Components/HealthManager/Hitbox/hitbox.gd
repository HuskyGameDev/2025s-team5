extends Area3D
class_name Hitbox

@export var health_manager : HealthManager 
var water_depth = 0

func _ready() -> void:
	assert(health_manager, "ERROR: health_manager must be set in hitbox inspector.")

func _physics_process(delta: float) -> void:
	if water_depth > 0: 
		pass #print(water_depth)

func take_damage(attack : Attack):
	health_manager.take_damage(attack)
