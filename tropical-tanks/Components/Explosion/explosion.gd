extends Node3D

const EXPLOSION = preload("res://Components/Explosion/explosion.tscn")
const CRATER = preload("res://Components/Crater/crater.tscn")

@onready var shape_cast = $ShapeCast3D

var explosion_power : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = randf_range(0.06,0.12)
	$Timer.start()
	$AudioStreamPlayer3D.volume_db = -5 + explosion_power
	$AudioStreamPlayer3D.play(0.0)
	$ExplosionModels.scale = scale * explosion_power * 2
	shape_cast.shape.radius = explosion_power / 2
	
	
	for child : MeshInstance3D in $ExplosionModels.get_children():
		child.rotation = Vector3(randf(),randf(),randf())
		
	var crater = CRATER.instantiate()
	crater.rotation.y = deg_to_rad(randi_range(1,360))
	crater.scale = crater.scale * explosion_power 
	get_tree().root.add_child(crater)
	crater.global_position = global_position
	
	shape_cast.force_shapecast_update()
	for collision in shape_cast.collision_result:
		var body = collision["collider"]
		if body.has_method("take_damage"):
			var explosion_attack : Attack = Attack.new()
			
			explosion_attack.attack_position = position
			explosion_attack.damage = (explosion_power * explosion_power * explosion_power + 1) 
			
			body.take_damage(explosion_attack)
	
	
# Animation 
func _on_timer_timeout() -> void:
	for i in randi_range(0,2):
		spawn_child_explosion()
	queue_free()
	
		
		
func spawn_child_explosion():
	var child_explosion_power = explosion_power - randf_range(1,3)
	if child_explosion_power > 0:
		var child_explosion = EXPLOSION.instantiate()
		child_explosion.explosion_power = child_explosion_power
		child_explosion.position = position + explosion_power * (Vector3(randf(),randf(),randf()) - Vector3.ONE * 0.5)
		get_tree().root.add_child(child_explosion)
		
