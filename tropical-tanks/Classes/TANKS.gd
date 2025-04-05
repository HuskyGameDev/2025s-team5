extends Node


const TANK = preload("res://Components/TankChassis/tankChassis.tscn")
const TANK_CONTROLLER = preload("res://Components/TankController/tankController.tscn")

func create_mob_tank() -> TankChassis:
	var tank : TankChassis = TANK.instantiate()
	var tank_controller : TankController = TANK_CONTROLLER.instantiate()
	tank.add_child(tank_controller)
	tank.add_to_group("Enemy")
	
	return tank
	
	
