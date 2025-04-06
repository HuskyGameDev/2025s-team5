extends Area3D
class_name Fire

const FIRE_PARTICLES = preload("res://Components/Fire/Fire.tscn")
var fire_strength : float = 10.0 :
	set(value):
		fire_strength = value
		_set_particles()
		if fire_strength <= 0:
			queue_free()
		$CollisionShape3D.shape.radius = fire_strength  / 5
const BURN_SCAR = preload("res://Components/Fire/burn_scar.tscn")
var fire_spread_chance = 0.2


func _ready() -> void:
	_set_particles()
	_create_burn_scar()
	
func _create_burn_scar():
	var burn_scar = BURN_SCAR.instantiate()
	get_tree().root.add_child(burn_scar)
	burn_scar.position = global_position
	burn_scar.rotation.y = randf() * TAU
	burn_scar.scale = burn_scar.scale * randf_range(1.0,2.0)
	
func _set_particles():
	var particle_amount_ratio : float = (1 - exp(-fire_strength / 10))
	$FireParticles.set_level(particle_amount_ratio)

func _on_fire_timer_timeout() -> void:
	if get_parent() is Hitbox:
		var hitbox : Hitbox = get_parent()
		var fire_attack = Attack.new()
		fire_attack.damage = fire_strength
		hitbox.take_damage(fire_attack)
		
		
		var true_flammability = hitbox.health_manager.flammability - hitbox.health_manager.fire_resistance
		true_flammability += randf_range(-0.1,0.1)
		fire_strength += (true_flammability - 0.5) * 10
		
	if randf() < fire_spread_chance:
		for area in get_overlapping_areas():
			if area is Hitbox:
				if area.health_manager.take_fire_damage == true:
					if area.fire == null:
						var new_fire = FIRE_PARTICLES.instantiate()
						area.add_child(new_fire)
						area.fire = new_fire
		
