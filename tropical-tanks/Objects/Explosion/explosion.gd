extends Node3D

const EXPLOSION = preload("res://Objects/Explosion/explosion.tscn")
const CRATER = preload("res://Objects/Crater/crater.tscn")

@onready var collider = $Area3D/CollisionShape3D

var explosion_power : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ExplosionModels.scale = scale * explosion_power * 3
	collider.shape.radius = explosion_power
	
	
	for child : MeshInstance3D in $ExplosionModels.get_children():
		child.rotation = Vector3(randf(),randf(),randf())
		
	var crater = CRATER.instantiate()
	crater.rotation.y = deg_to_rad(randi_range(1,360))
	crater.scale = crater.scale * explosion_power
	get_tree().root.add_child(crater)
	crater.global_position = global_position
	
	
# Animation 
func _on_timer_timeout() -> void:
	for i in randi_range(0,2):
		spawn_child_explosion()
	queue_free()
	
		
		
func spawn_child_explosion():
	var child_explosion_power = explosion_power - 1
	if child_explosion_power > 0:
		var child_explosion = EXPLOSION.instantiate()
		child_explosion.explosion_power = child_explosion_power
		child_explosion.position = position + (Vector3(randf(),randf(),randf()) - Vector3.ONE * 0.5)
		get_tree().root.add_child(child_explosion)
		


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		var explosion_attack : Attack = Attack.new()
		
		explosion_attack.attack_position = position
		explosion_attack.damage = (explosion_power * explosion_power * explosion_power) 
		
		body.take_damage(explosion_attack)
