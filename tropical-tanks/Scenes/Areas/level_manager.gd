extends Node3D

enum gamemode_types {
	EndlessSurvival, 
	TeamDeathmatch, 
	Creative,
	}

var gamemodes = {
	gamemode_types.EndlessSurvival : preload("res://Scenes/Gamemodes/Survival/Survival.tscn"),
	
}

@export var area_name : String = "Unnamed Area"
@export var area_panel_background : Texture = preload("res://Art/Images/TropicalBanner.png")
@export var gamemode_type : gamemode_types = gamemode_types.EndlessSurvival

var gamemode : Gamemode

func _ready() -> void:
	if !gamemodes.has(gamemode_type):
		push_warning("Selected gamemode is not implemented!")
	gamemode = gamemodes[gamemode_type].instantiate()
	add_child(gamemode)
	
	
