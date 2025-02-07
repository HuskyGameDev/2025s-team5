extends Node3D

var health = 3
func damage(attack : Attack):
	health -= attack.damage
