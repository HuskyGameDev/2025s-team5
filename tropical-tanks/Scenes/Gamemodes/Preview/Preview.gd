extends Gamemode

var enemies : Array[TankChassis] = []
@onready var cam_target = $Camera3D.position

func _ready() -> void:
	spawn_enemy()
	spawn_enemy()
	spawn_enemy()
	SIGNALBUS.tankDestroyed.connect(_tank_destroyed)
		
	
func _process(delta: float) -> void:
	var avg_pos = Vector3.ZERO
	var i = 0
	for enemy in enemies:
		if enemy:
			i += 1
			avg_pos += enemy.global_position
	avg_pos = avg_pos / i
	cam_target = cam_target.move_toward(avg_pos + Vector3(0,40,0),delta * 4)
	$Camera3D.position = $Camera3D.position.move_toward(cam_target,delta * 6)

	
func spawn_enemy():
	var tank = TANKS.create_mob_tank()
	var pos = Vector3(randi_range(-50,50),40,randi_range(-50,50))
	tank.position = pos
	print(get_tree().root.get_child(0))
	get_parent().add_child(tank)
	enemies.append(tank)
	GLOBAL.aging_factor = exp(enemies.size()/5)

func _tank_destroyed(tank : TankChassis, position):
	if enemies.has(tank):
		enemies.erase(tank)

func _on_timer_timeout() -> void:
	if enemies.size() <= 5:
		spawn_enemy()
