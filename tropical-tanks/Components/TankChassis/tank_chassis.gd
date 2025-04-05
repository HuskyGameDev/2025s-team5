extends CharacterBody3D
class_name TankChassis

@export var SPEED = 500.0
@export var tank_rotation : float = 0.0
@export var upgrades : Array[Upgrade] = []


@onready var ground_cast : ShapeCast3D  = $GroundCast
@onready var damage_cast: ShapeCast3D = $DamageCast

@onready var tank_model = $TankChassisModelParts
@onready var health_manager : HealthManager = $HealthManager

var turrets_count : int = 1
@onready var turret_mounts : Array[TurretMount] = [$TurretMount]


var view_range = 20

var controls = {
	"forward" = false,
	"backward" = false,
	"turn_left" = false,
	"turn_right" = false,
	"shoot" = false,
	
}


func _ready() -> void:
	for i in turrets_count:
		if i < turret_mounts.size():
			turret_mounts[i].has_turret = true

func get_turrets() -> Array[Turret]:
	var turrets : Array[Turret] = []
	for turret_mount in turret_mounts:
		if turret_mount.turret:
			turrets.append(turret_mount.turret)
	return turrets

func on_upgrade_pickup(U : Upgrade):
	upgrades.append(U)
	for turret  in get_turrets():
		turret.initial_shot_power += U.initial_shot_power
		turret.split_barrels += U.split_barrel
		turret.double_barrels += U.double_barrel
		turret.shell_parameters.armor_piercing += U.armor_piercing
		turret.shell_parameters.backwardness += U.backwardness
		turret.shell_parameters.bounces_left += U.bounces_left
		turret.shell_parameters.bounce_explode += U.bounce_explode
		turret.shell_parameters.bounce_loss += U.bounce_loss
		turret.shell_parameters.drag += U.drag
		turret.shell_parameters.evaporation += U.evaporation
		turret.shell_parameters.explosion_power += U.explosion_power
		turret.shell_parameters.flame_effect += U.flame_effect
		turret.shell_parameters.fuel += U.fuel
		turret.shell_parameters.fuse_time += U.fuse_time
		turret.shell_parameters.ice_effect += U.ice_effect
		turret.shell_parameters.mass += U.mass
		turret.shell_parameters.thrust_power += U.thrust_power
		turret.shell_parameters.num_fuse += U.num_fuse
	
		view_range = turret.initial_shot_power/turret.shell_parameters.mass


var move_vector = Vector3(0,0,-1)
func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	var move_normal = Vector3(0,1,0)
	move_vector = Vector3(0,0,-1).rotated(move_normal,tank_rotation)
	
	if damage_cast.is_colliding():
		var collision_attack : Attack = Attack.new()
		collision_attack.damage = velocity.length() + 1
		for i in damage_cast.collision_result.size():
			var collider = damage_cast.get_collider(i)
			if collider is Hitbox:
				collider.take_damage(collision_attack)
	
	if ground_cast.is_colliding():
		
		
		velocity = Vector3.ZERO #velocity.move_toward(Vector3.ZERO,delta * 25)
	

		#position += ground_cast.get_collision_point() - ground_cast.global_position - ground_cast.target_position
		
		
		var rotation_axis = (move_normal.cross(ground_cast.get_collision_normal(0))).normalized()
		var move_vector_angle = move_normal.angle_to(ground_cast.get_collision_normal(0))
		
		if controls.get("forward"):
			velocity = (delta * SPEED * move_vector)
			if move_vector_angle != 0 and velocity != Vector3.ZERO:
				velocity = velocity.rotated(rotation_axis,move_vector_angle)
		if controls.get("backward"):
			velocity = (delta * -SPEED * move_vector) #.rotated(rotation_axis.normalized(),move_vector_angle)
			if move_vector_angle != 0 and velocity != Vector3.ZERO:
				velocity = velocity.rotated(rotation_axis, -move_vector_angle)

		if controls.get("turn_left"):
			tank_rotation += 1.3 * delta
		if controls.get("turn_right"):
			tank_rotation += -1.3 * delta
	
		
		#if move_vector_angle != 0 and velocity != Vector3.ZERO:
		#	velocity = velocity.rotated(rotation_axis,move_vector_angle)
			#look_at(global_position + move_vector.rotated(rotation_axis,move_vector_angle))
			#tank_model.look_at(global_poswition + move_vector.rotated(rotation_axis,move_vector_angle))
			
	elif !is_on_floor():
		velocity += get_gravity() * delta
		
	if controls.get("shoot"):
		for turret in get_turrets():
			turret.shoot()
	look_at(global_position + move_vector)
	move_and_slide()

func on_death():
	SIGNALBUS.tankDestroyed.emit(self, global_position)

func take_damage(attack : Attack):
	print("DAMAGE WRONG")
	health_manager.take_damage(attack)
	
