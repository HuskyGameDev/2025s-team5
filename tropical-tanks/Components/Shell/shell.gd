extends Node3D
class_name Shell

const FIRE = preload("res://Components/Fire/Fire.tscn")
const EXPLOSION = preload("res://Components/Explosion/explosion.tscn")
const SHELL = preload("res://Components/Shell/shell.tscn")

var parent_body : Node3D

var velocity : Vector3 = Vector3(0,0,0)
var power : float = 0 # Total power of the bullet based on speed * mass

@onready var shape_cast : ShapeCast3D = $ShapeCast3D
@onready var ray_cast: RayCast3D = $RayCast3D


@export var shell_parameters : ShellParameter
@onready var sp : ShellParameter = shell_parameters

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sp.bounces_left > 0:
		$BounceMesh.show()
		
	scale = Vector3.ONE * pow(sp.mass,0.3333)
	# Start Fuse timer
	if sp.num_fuse > 0:
		$FuseTimer.wait_time = sp.fuse_time
		$FuseTimer.start()
		
	# Reverse bullet for every other level of backwardness
	if int(sp.backwardness) % 2 == 1:
		$TempMesh.rotation.y = deg_to_rad(180)

func split():
	spawn_shell()

func spawn_shell():
	var shell : Shell = SHELL.instantiate()
	shell.shell_parameters = sp.duplicate()
	shell.velocity = velocity * 2
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
	sp.bounces_left -= 1 # Decrement bounce counter
	if sp.bounces_left <= 0:
		$BounceMesh.hide()
	
	
	if sp.num_split > 0:
		split()
		sp.num_split -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta: float) -> void:
	# Ray Cast collisions
	var inst_speed_vector =  velocity.length() * delta * Vector3(0,0,-1) ## Instantaneous speed of the shell
	ray_cast.target_position = inst_speed_vector
	shape_cast.target_position = inst_speed_vector
	check_collisions(inst_speed_vector)

	# Integrate position and velocity
	position += velocity * delta
	velocity += shell_parameters.gravity * delta + get_drag() * delta # Decreases velocity by the drag constant
	
	# Look in direction of travel
	look_at(position + velocity)

func check_collisions(delta_velocity):
	
	if ray_cast.is_colliding():
		var collision_point = ray_cast.get_collision_point()
		var cast_global_positon = ray_cast.global_position
		
		
		power = velocity.length() * sp.mass
	
		var collision_vector = collision_point - cast_global_positon
		if (collision_vector.length()) <= 1.0:
			
			#position += collision_vector
			if sp.bounces_left >= 1:
				bounce(ray_cast.get_collision_normal())
			else:
				explode()
				queue_free()

	if shape_cast.is_colliding():
		var area = shape_cast.get_collider(0)
		if parent_body and area:
			if !parent_body.health_manager.hitboxes.has(area):
				position += delta_velocity
				if area.get_parent().is_in_group("Enemy"): # Explode and bounce if the collision is with an enemy object and is able to bounce
					explode()
					impact(area)
				else : # Only bounce if hitting terrain and is able to bounce
					if sp.bounces_left >= 1:
						bounce(ray_cast.get_collision_normal())
					else:
						explode() # Otherwise, just explode
						impact(area)

func get_drag() -> Vector3:
	return -(velocity*velocity.length()) * sp.drag * 0.5 # Returns a drag vector to factor in to velocity

## Explode
func explode():
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	explosion.explosion_power = sp.explosion_power * sp.mass 
	get_tree().root.add_child(explosion)
	#if(sp.num_split > 0):
		#sp.num_split -= 1
		#split()

## Apply Kinetic damage through an imapct
func impact(body : Node3D):
	#if sp.flame_effect > 0:
		#var fire = FIRE.instantiate()
		#fire.fire_strength = sp.flame_effect
		#get_tree().root.add_child(fire)
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
		#for i in sp.num_split:
			#sp.num_split = 0
			#split()
		split()
		sp.num_split -= 1


func _on_life_timer_timeout() -> void:
	queue_free()
