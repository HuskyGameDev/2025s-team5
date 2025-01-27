extends Node3D
class_name Shell


const EXPLOSION = preload("res://Objects/Explosion/explosion.tscn")

var velocity : Vector3 = Vector3(0,0,0)
var gravity : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
var mass : float = 1.0
var ap_power : float = 0.0
var expl_power : float = 1.0
var evap : float = 1.0
var bounce : float = 0.0
var fuse = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	
	
	position += velocity * delta
	velocity += gravity * delta
	pass

func explode():
	
	
	print("Shell Explode!")
	
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	explosion.explosion_power = 2
	get_tree().root.add_child(explosion)

	
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	explode()
