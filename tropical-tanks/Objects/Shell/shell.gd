extends Node3D
class_name Shell


const EXPLOSION = preload("res://Objects/Explosion/explosion.tscn")

var velocity : Vector3 = Vector3(0,0,0)
var gravity : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
var power : float = 0 # Total power of the bullet based on speed * mass

## Physics Variables
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
@export var bounces_left : float = 0.0:
	set(value):
		bounces_left = value
		
## Mid Flight Control Variables
@export var fuse_time : float = 2.0
@export var fuel : float = 0.0
@export var thrust_power : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if fuse_time > 0.2:
		$FuseTimer.wait_time = fuse_time
		$FuseTimer.start()

func fuse():
	explode()
	
	# TODO: Write code to trigger bullet split upgrades after the fuse upgrade has been unlocked
	
func bounce():
	# TODO: Calculate new bullet vector based on how the bullet hits the object
	bounces_left -= 1 # Decrement bounce counter
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	power = velocity.length() * mass
	
	position += velocity * delta
	velocity += gravity * delta + get_drag() * delta # Decreases velocity by the drag constant
	look_at(position + velocity) # Look in direction of travel
	pass

func get_drag() -> Vector3:
	return -(velocity*velocity.length()) * drag * 0.5 # Returns a drag vector to factor in to velocity

func explode():
	print("Shell Explode!")
	
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	explosion.explosion_power = explosion_power
	get_tree().root.add_child(explosion)
	if bounces_left < 1:
		queue_free() # Delete shell object if there are no more bounces remaining

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"): # Explode and bounce if the collision is with an enemy object and is able to bounce
		if bounces_left > 1:
			explode()
			bounce()
		else : # Otherwise, just explode
			explode()
	else : # Only bounce if hitting terrain and is able to bounce
		if bounces_left > 1:
			bounce()
		explode() # Otherwise, just explode


func _on_fuse_timer_timeout() -> void:
	fuse()
