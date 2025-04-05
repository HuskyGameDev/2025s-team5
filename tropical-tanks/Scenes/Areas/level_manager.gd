extends Node3D

enum gamemodes {
	EndlessSurvival, 
	TeamDeathmatch, 
	Creative,
	}

@export var gamemode_type : gamemodes = gamemodes.EndlessSurvival

var gamemode : Gamemode

func _ready() -> void:
	match gamemode_type:
		gamemodes.EndlessSurvival:
			gamemode = SurvivalGamemode.new()
		gamemodes.TeamDeathmatch:
			pass
		gamemodes.Creative:
			pass
	assert(gamemode, "Selected gamemode is not implemented")
	add_child(gamemode)
	
	
