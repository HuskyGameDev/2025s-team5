extends Node3D
class_name Explosion

const EXPLOSION = preload("res://Components/Explosion/explosion.tscn")
const CRATER = preload("res://Components/Crater/crater.tscn")

@onready var shape_cast = $ShapeCast3D
@onready var crater_cast: RayCast3D = $CraterCast

@export var explosion_power : float = 1

var is_child = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = randf_range(0.05,0.1)
	$Timer.start()
	$AudioStreamPlayer3D.volume_db = -5 + explosion_power
	$AudioStreamPlayer3D.play(0.0)
	$ExplosionModels.scale = scale * explosion_power * 2
	shape_cast.shape.radius = explosion_power / 2
	
	
	for child : MeshInstance3D in $ExplosionModels.get_children():
		child.rotation = Vector3(randf(),randf(),randf())
	
	if !is_child:
		spawn_crater()
	else:
		if randf() > (1.0 / explosion_power):
			spawn_crater()
	
	await get_tree().physics_frame
	if explosion_power > 1.0:
		shape_cast.force_shapecast_update()
		for collision in shape_cast.collision_result:
			var body = collision["collider"]
			if body.has_method("take_damage"):
				var explosion_attack : Attack = Attack.new()
				
				explosion_attack.attack_position = position
				explosion_attack.damage = (explosion_power * explosion_power + 1) 
				
				body.take_damage(explosion_attack)
	
	
# Animation 
func _on_timer_timeout() -> void:
	if explosion_power > 6:
		spawn_child_explosion()
	if explosion_power < 6:
		for i in randi_range(0,1):
			spawn_child_explosion()
	queue_free()
	
func spawn_crater():
	crater_cast.force_raycast_update()
	if crater_cast.is_colliding():
		var crater : Crater = CRATER.instantiate()
		#crater.rotation.y = randf() * 2 * PI
		var floor_normal = crater_cast.get_collision_normal()
		var terrain = crater_cast.get_collider().get_parent().get_parent()
		crater.terrain = terrain
		terrain.add_child(crater)
		crater.basis.y = floor_normal
		crater.basis.x = -crater.basis.z.cross(floor_normal)
		crater.basis = crater.basis.orthonormalized()
		
		crater.mesh_instance_3d.scale = crater.scale * explosion_power 
		crater.global_position = crater_cast.get_collision_point()
		
	
func spawn_child_explosion():
	var child_explosion_power = explosion_power - randf_range(1,3)
	if child_explosion_power > 1:
		var child_explosion = EXPLOSION.instantiate()
		child_explosion.is_child = true
		child_explosion.explosion_power = child_explosion_power
		child_explosion.position = position + 2 * sqrt(explosion_power) * (Vector3(randf_range(-0.5,0.5),randf_range(0,0.5),randf_range(-0.5,0.5)))
		get_tree().root.add_child(child_explosion)
		
