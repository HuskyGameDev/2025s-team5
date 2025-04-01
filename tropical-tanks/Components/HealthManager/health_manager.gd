extends Node3D
class_name HealthManager

@export var max_health : float = 100.0
@export var death_effects : Array[Resource]
@export var take_water_damage : bool = false

@export var take_fire_damage : bool = true
@export var fire_resistance : float = 0.5

@export var indicators : bool = false ## If [code]true[/code], spawn indicators upon damage.

var INDICATOR = preload("res://Components/Indicator/indicator.tscn")

var fire_level : float = 0
var fire_speed : float = 0.1

var health = max_health
func take_damage(attack : Attack):
	if health > 0:
		if indicators: spawn_indicator(attack.damage, Color(0.9,0.1,0.1))
		
		health = health - attack.damage
		if take_water_damage:
			health = health - attack.water_depth
			if indicators: spawn_indicator(attack.water_depth, Color(0.1,0.5,0.1))
		#fire_level += attack.flame_effect
		
		check_health()
		
func check_health():
		if health <= 0:
			death()

func spawn_indicator(value, color : Color):
	var spread_distance = 2
	var indicator : Indicator = INDICATOR.instantiate()
	indicator.text = str("-",snapped(value,0))
	indicator.color = color
	get_tree().root.add_child(indicator)
	indicator.global_position = global_position + (Vector3(spread_distance,0,0).rotated(Vector3(0,1,0),randf() * 2*PI) * randf())

func _physics_process(delta: float) -> void:
	pass
	#if take_fire_damage and fire_level > 0 and health > 0:
		#do_fire_damage(delta)
		#fire_particles.set_level( clampf(fire_level/40,0.0,1.0) )
	#else:
		#fire_particles.stop()

func do_fire_damage(delta: float):
	print(fire_level)
	var percent_health = health/max_health # The percent health
	var fire_damage = fire_level * fire_level * fire_speed * delta
	health -= fire_damage
	if percent_health > fire_resistance:
		fire_level -= (fire_damage) * fire_resistance
		if fire_level < 1:
			fire_level = 0
	check_health()
		
		
	

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
