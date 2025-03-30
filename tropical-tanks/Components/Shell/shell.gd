extends Node3D
class_name Shell

const EXPLOSION = preload("res://Components/Explosion/explosion.tscn")
const SHELL = preload("res://Components/Shell/shell.tscn")

var velocity : Vector3 = Vector3(0,0,0)
var power : float = 0 # Total power of the bullet based on speed * mass

@onready var shape_cast : ShapeCast3D = $ShapeCast3D
@onready var ray_cast: RayCast3D = $RayCast3D


@export var shell_parameters : ShellParameter
@onready var sp : ShellParameter = shell_parameters

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start Fuse timer
	if sp.num_fuse > 0:
		$FuseTimer.wait_time = sp.fuse_time
		$FuseTimer.start()
		
	# Reverse bullet for every other level of backwardness
	if int(sp.backwardness) % 2 == 1:
		$TempMesh.rotation.y = deg_to_rad(180)

func split(index):
	
	spawn_shell()

func spawn_shell():
	var shell : Shell = SHELL.instantiate()
	shell.shell_parameters = sp.duplicate()
	shell.velocity = velocity * .5
	shell.rotation = global_rotation
	shell.position = global_position
	get_tree().root.add_child(shell)

func bounce(normal_vector : Vector3):
	# Explode and remove bullet if speed is too low to bounce
	if(velocity.length() < 5):
		explode()
		queue_free()
	
	# Calculate plane to mirror the bullet, in vector form
	var rotation_axis = normal_vector.cross(velocity).normalized()
	var reflection_plane = normal_vector.rotated(rotation_axis, PI/2)
	
	# Explode when bounce_explode is high, chance to explode when below 1
	if sp.bounce_explode >= 1 or randf_range(0.0,1.0) < sp.bounce_explode:
		explode()
		
	velocity = velocity.reflect(reflection_plane) * (1.0 - sp.bounce_loss/sp.bounces_left)
	sp.bounces_left = sp.bounces_left - 1 # Decrement bounce counter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Ray Cast collisions
	ray_cast.target_position = velocity.length() * delta * Vector3(0,0,-1)
	check_collisions()

	# Integrate position and velocity
	position += velocity * delta
	velocity += shell_parameters.gravity * delta + get_drag() * delta # Decreases velocity by the drag constant
	
	# Look in direction of travel
	look_at(position + velocity)

func check_collisions():
	
	if ray_cast.is_colliding():
		var collision_point = ray_cast.get_collision_point()
		var cast_global_positon = ray_cast.global_position
		
		
		power = velocity.length() * sp.mass
	
		var collision_vector = collision_point - cast_global_positon
		print((collision_vector.length()))
		if (collision_vector.length()) <= 1.0:
			
			#position += collision_vector
			
			var body = ray_cast.get_collider()
			if body:
				if body.get_parent().is_in_group("Enemy"): # Explode and bounce if the collision is with an enemy object and is able to bounce
					explode()
					impact(body)
					print("hit enemy")
				else : # Only bounce if hitting terrain and is able to bounce
					if sp.bounces_left >= 1:
						bounce(ray_cast.get_collision_normal())
					else:
						explode() # Otherwise, just explode
						impact(body)

func get_drag() -> Vector3:
	return -(velocity*velocity.length()) * sp.drag * 0.5 # Returns a drag vector to factor in to velocity

## Explode
func explode():
	print(sp.num_fuse)
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	explosion.explosion_power = sp.explosion_power
	get_tree().root.add_child(explosion)
	#if(sp.num_split > 0):
		#sp.num_split -= 1
		#split()

## Apply Kinetic damage through an imapct
func impact(body : Node3D):
	# Create new Attack
	var impact_attack : Attack = Attack.new()
	
	# Set attack variables
	impact_attack.damage = velocity.length() * sp.mass  # Set attack damage to the momentum of the shell #Momentum = Velocity * Mass
	impact_attack.armor_piercing = sp.armor_piercing
	impact_attack.ice_effect = sp.ice_effect
	impact_attack.flame_effect = sp.flame_effect * sp.mass
	
	
	# Apply attack to body
	if body.has_method("take_damage"):
		body.take_damage(impact_attack)
	queue_free()

func _on_fuse_timer_timeout() -> void:
	explode()
	sp.num_fuse -= 1
	if(sp.num_fuse > 0):
		$FuseTimer.start()
	else :
		for i in sp.num_split:
			sp.num_split = 0
			split(i)
