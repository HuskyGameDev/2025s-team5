extends Gamemode
class_name SurvivalGamemode

const PLAYER = preload("res://Objects/Player/player.tscn")
const UPGRADE_POOL = preload("res://Resources/UpgradePools/basic_upgrades.tres")
const PICKUP = preload("res://Objects/Pickups/Pickup.tscn")

var enemies : Array[TankChassis] = []

var wave_timer : Timer
func _ready() -> void:
	_wave_timer()
	
	#connect("PlayerDestroyed", _enemy_destroyed)
	SIGNALBUS.tankDestroyed.connect(_tank_destroyed)
	
	spawn_player()
	next_wave()
	
func spawn_player():
	var player = PLAYER.instantiate()
	player.position = Vector3(0,30,0)
	get_tree().root.add_child(player)
	
func spawn_enemy():
	var tank = TANKS.create_mob_tank()
	var pos = Vector3(randi_range(-100,100),40,randi_range(-100,100))
	tank.position = pos
	get_tree().root.add_child(tank)
	enemies.append(tank)
	
	

func _player_destroyed():
	pass

var experience :int = 0
func _tank_destroyed(tank : TankChassis, position):
	if enemies.has(tank):
		experience += randi_range(3,5)
		enemies.erase(tank)
		if experience > 10:
			if position.y > 0:
				experience -= 10
				spawn_pickup(position)
		
			
func spawn_pickup(pos : Vector3):
	var pickup : Pickup = PICKUP.instantiate()
	pickup.upgrade = UPGRADE_POOL.select_upgrade()
	get_tree().root.add_child(pickup)
	pickup.global_position = pos
	

func _wave_timer():
	wave_timer = Timer.new()
	wave_timer.wait_time = 20
	add_child(wave_timer)
	wave_timer.start()
	wave_timer.connect("timeout",next_wave)
	
func next_wave():
	for i in randi_range(3,5):
		spawn_enemy()
	
