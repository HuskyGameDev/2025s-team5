extends Area3D
class_name Hitbox

@export var health_manager : HealthManager 
var water_depth = 0
var fire : Fire

func _ready() -> void:
	health_manager.hitboxes.append(self)
	assert(health_manager, "ERROR: health_manager must be set in hitbox inspector.")

func _physics_process(_delta: float) -> void:
	if water_depth > 0:
		if health_manager.water_damage_timer.is_stopped():
			health_manager.do_water_damage()

func take_damage(attack : Attack):
	health_manager.take_damage(attack)
