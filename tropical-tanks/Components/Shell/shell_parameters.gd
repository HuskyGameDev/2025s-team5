extends Resource
class_name ShellParameter


var gravity : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity") * 2
@export var mass : float = 1.0
@export var drag : float = 0.001 # Mathematically, cross sectional area of the bullet
		
## Gameplay Variables
@export var armor_piercing : float = 1.0
@export var explosion_power : float = 5.0 
@export var evaporation : float = 0.0 # Bullet shrink over time
@export var bounces_left : float = 2.0 

@export var bounce_loss : float = 0.4 # What percent of velocity is lost in a bounce
@export var bounce_explode : float = 0.0

@export var ice_effect : float = 0.0 # Amount to freeze
@export var flame_effect : float = 0.0 # Amount to burn

@export var num_split : int = 0

		
## Mid Flight Control Variables
@export var fuse_time : float = 0.5
@export var num_fuse : int = 0
@export var fuel : float = 0.0
@export var thrust_power : float = 1.0
@export var backwardness : float = 0.0 # How backward the shell is
