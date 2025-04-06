extends Gamemode
class_name SurvivalGamemode

const PLAYER = preload("res://Objects/Player/player.tscn")
const UPGRADE_POOL = preload("res://Resources/UpgradePools/basic_upgrades.tres")
const PICKUP = preload("res://Objects/Pickups/Pickup.tscn")

var enemies : Array[TankChassis] = []

@onready var wave_timer : Timer = $WaveTimer
var wave = 0
func _ready() -> void:
	
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
	if enemies.size() <= 0:
		next_wave()
			
func spawn_pickup(pos : Vector3):
	var pickup : Pickup = PICKUP.instantiate()
	pickup.upgrade = UPGRADE_POOL.select_upgrade()
	get_tree().root.add_child(pickup)
	pickup.global_position = pos
	

	
func next_wave():
	wave_timer.start()
	if enemies.size() > wave / 2 + 1:
		return
	wave += 1
	$CanvasLayer/PanelContainer/HBoxContainer/WaveNumber.text = str(wave)
	
	var extra = 0
	if wave > 3:
		extra = randi_range(0, wave - 2)
	spawn_enemy()
	while enemies.size() < extra:
		spawn_enemy()
	
func _on_wave_timer_timeout() -> void:
	next_wave()
