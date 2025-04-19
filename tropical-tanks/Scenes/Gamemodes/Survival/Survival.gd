extends Gamemode
class_name SurvivalGamemode

const PLAYER = preload("res://Objects/Player/player.tscn")
const UPGRADE_POOL = preload("res://Resources/UpgradePools/basic_upgrades.tres")
const PICKUP = preload("res://Objects/Pickups/Pickup.tscn")
const ENEMY_UPGRADE_POOL = preload("res://Resources/UpgradePools/enemy_upgrades.tres")
var enemies : Array[TankChassis] = []

@onready var wave_timer : Timer = $WaveTimer
var wave = 0
func _ready() -> void:
	SIGNALBUS.tankDestroyed.connect(_tank_destroyed)
	
	spawn_player()
	next_wave()
	
func spawn_player():
	var player = PLAYER.instantiate()
	player.position = Vector3(0,30,0)
	get_parent().add_child(player)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func spawn_enemy():
	var tank = TANKS.create_mob_tank()
	var pos = Vector3(randi_range(-70,70),40,randi_range(-70,70))
	
	tank.position = pos
	tank.rotation
	tank.health = 25
	tank.health = tank.health + wave * 5
	if wave < 10:
		tank.speed = .8 * tank.speed
		
	get_parent().add_child(tank)
	enemies.append(tank)
	GLOBAL.aging_factor = exp(enemies.size()/5)
	
	if wave > 3:
		for i in wave - 3:
			if randf() < 0.1:
				tank.on_upgrade_pickup(ENEMY_UPGRADE_POOL.select_upgrade())
	
#func _process(delta: float) -> void:
	#pass
	#if Input.is_action_just_pressed("spawn_pickup"):
			#spawn_enemy()

func _player_destroyed():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over()

var experience :int = 15
var upgrade_cost = 5
func _tank_destroyed(tank : TankChassis, position):
	if tank.is_in_group("Player"):
		_player_destroyed()
		return
	if enemies.has(tank):
		experience += randi_range(3,5)
		enemies.erase(tank)
		if experience > upgrade_cost:
			if position.y > 0:
				experience -= upgrade_cost
				spawn_pickup(position)
				upgrade_cost += 1
	if enemies.size() <= 0:
		next_wave()
			
func spawn_pickup(pos : Vector3):
	var pickup : Pickup = PICKUP.instantiate()
	pickup.upgrade = UPGRADE_POOL.select_upgrade()
	get_parent().add_child(pickup)
	pickup.global_position = pos
	
func game_over():
	await get_tree().create_timer(0.5).timeout
	$CanvasLayer/GameOver.show()
	
func next_wave():
	wave_timer.start()
	if wave < 4:
		if enemies.size() > 0:
			return
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


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/main_menu.tscn")
