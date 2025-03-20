extends Resource
class_name Upgrade

@export var image : CompressedTexture2D

@export var double_barrel : int = 0
@export var split_barrel : int = 0
@export var mass : float = 0
# Mathematically, cross sectional area of the bullet
@export var drag : float = 0

## Gameplay Variables
@export var armor_piercing : float = 0
@export var explosion_power : float = 0
# Bullet shrink over time
@export var evaporation : float = 0
@export var bounces_left : float = 0
# What percent of velocity is lost in a bounce
@export var bounce_loss : float = 0
@export var bounce_explode : float = 0
# Amount to freeze
@export var ice_effect : float = 0
# Amount to burn
@export var flame_effect : float = 0

## Mid Flight Control Variables
@export var fuse_time : float = 0
@export var fuel : float = 0
@export var thrust_power : float = 0
# How backward the shell is
@export var backwardness : float = 0
