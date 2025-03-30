extends Node3D
class_name FireParticles

@onready var fire_particles_2: GPUParticles3D = $FireParticles2
@onready var sprite_3d: Sprite3D = $Sprite3D

func set_level(level):
	fire_particles_2.amount_ratio = level
	sprite_3d.show()

func stop():
	fire_particles_2.amount_ratio = 0.0
	sprite_3d.hide()
