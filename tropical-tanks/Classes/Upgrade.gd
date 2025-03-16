extends Resource
class_name Upgrade

@export var double_barrel : int = 0 :
	set(value):
		double_barrel = value
@export var split_barrel : int = 0 :
	set(value):
		split_barrel = value
@export var mass : float = 0 :
	set(value):
		mass = value
# Mathematically, cross sectional area of the bullet
@export var drag : float = 0 :
	set(value):
		drag = value

## Gameplay Variables
@export var armor_piercing : float = 0 :
	set(value):
		armor_piercing = value
@export var explosion_power : float = 0 :
	set(value):
		explosion_power = value
# Bullet shrink over time
@export var evaporation : float = 0 :
	set(value):
		evaporation = value
@export var bounces_left : float = 0 :
	set(value):
		bounces_left = value
# What percent of velocity is lost in a bounce
@export var bounce_loss : float = 0 :
	set(value):
		bounce_loss = value
@export var bounce_explode : float = 0 :
	set(value):
		bounce_explode = value
# Amount to freeze
@export var ice_effect : float = 0 :
	set(value):
		ice_effect = value
# Amount to burn
@export var flame_effect : float = 0 :
	set(value):
		flame_effect = value

## Mid Flight Control Variables
@export var fuse_time : float = 0 :
	set(value):
		fuse_time = value
@export var fuel : float = 0 :
	set(value):
		fuel = value
@export var thrust_power : float = 0 :
	set(value):
		thrust_power = value
# How backward the shell is
@export var backwardness : float = 0 :
	set(value):
		backwardness = value
