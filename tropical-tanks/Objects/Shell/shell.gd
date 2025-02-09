extends Node3D
class_name Shell


const EXPLOSION = preload("res://Objects/Explosion/explosion.tscn")

var velocity : Vector3 = Vector3(0,0,0)
var gravity : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
var power : float = 0 # Total power of the bullet based on speed * mass

@onready var cast = $RayCast3D

## Physics Variables
var shell_variables = {
}
@export var mass : float = 1.0 :
	set(value):
		mass = value
@export var drag : float = 0.1 : # Mathematically, cross sectional area of the bullet
	set(value):
		drag = value
		
## Gameplay Variables
@export var armor_piercing : float = 1.0 :
	set(value):
		armor_piercing = value
@export var explosion_power : float = 1.0 :
	set(value):
		explosion_power = value
@export var evaporation : float = 1.0:
	set(value):
		evaporation = value
@export var bounces_left : float = 4.0:
	set(value):
		bounces_left = value
@export var bounce_loss : float = 0.4 #What percent of velocity is lost in a bounce
@export var bounce_explode : float = 0.1
		
## Mid Flight Control Variables
@export var fuse_time : float = 5.0
@export var fuel : float = 0.0
@export var thrust_power : float = 1.0
@export var backwardness : float = 0.0 # How backward the shell is

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start Fuse timer
	if fuse_time > 0.2:
		$FuseTimer.wait_time = fuse_time
		$FuseTimer.start()
		
	# Reverse bullet for every other level of backwardness
	if int(backwardness) % 2 == 1:
		$TempMesh.rotation.y = deg_to_rad(180)

func fuse():
	explode()
	queue_free()
	
	# TODO: Write code to trigger bullet split upgrades after the fuse upgrade has been unlocked
	
func bounce(normal_vector : Vector3):
	# Calculate plane to mirror the bullet, in vector form
	var rotation_axis = normal_vector.cross(velocity).normalized()
	var reflection_plane = normal_vector.rotated(rotation_axis, PI/2)
	
	# Explode when bounce_explode is high, chance to explode when below 1
	if bounce_explode >= 1 or randf_range(0.0,1.0) < bounce_explode:
		explode()
		
	velocity = velocity.reflect(reflection_plane) * (1.0 - bounce_loss/bounces_left)
	bounces_left = bounces_left - 1 # Decrement bounce counter
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Ray Cast collisions
	if cast.is_colliding():
		
		power = velocity.length() * mass
		var collision_vector = cast.get_collision_point() - cast.global_position
		if (collision_vector.length() - velocity.length() * delta) <= 0:
			
			position += collision_vector
			
			var body = cast.get_collider()
			if body.is_in_group("Enemy"): # Explode and bounce if the collision is with an enemy object and is able to bounce
				explode()
				impact(body)
				print("hit enemy")
			else : # Only bounce if hitting terrain and is able to bounce
				if bounces_left >= 1:
					bounce(cast.get_collision_normal())
				else:
					explode() # Otherwise, just explode
					impact(body)

	# Integrate position and velocity
	position += velocity * delta
	velocity += gravity * delta + get_drag() * delta # Decreases velocity by the drag constant
	
	# Look in direction of travel
	look_at(position + velocity)

func get_drag() -> Vector3:
	return -(velocity*velocity.length()) * drag * 0.5 # Returns a drag vector to factor in to velocity

## Explode
func explode():
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	explosion.explosion_power = explosion_power
	get_tree().root.add_child(explosion)

## Apply Kinetic damage through an imapct
func impact(body : Node3D):
	# Create new Attack
	var impact_attack : Attack = Attack.new()
	impact_attack.damage = velocity.length() * mass
	impact_attack.armor_piercing = armor_piercing
	
	# Apply attack to body
	if body.has_method("take_damage"):
		body.take_damage(impact_attack)
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	return
	
	#if body.is_in_group("Enemy"): # Explode and bounce if the collision is with an enemy object and is able to bounce
		#explode()
	#else : # Only bounce if hitting terrain and is able to bounce
		#if bounces_left > 0:
			#bounce(cast.get_collision_normal())
		#else:
			#explode() # Otherwise, just explode


func _on_fuse_timer_timeout() -> void:
	fuse()
