extends Node

const FPS_LABEL = preload("res://Components/FPSLabel/fps_label.tscn")

var fps_label : Label
var SHOW_FPS : bool  = true :
	set(value):
		SHOW_FPS = value
		if SHOW_FPS == true:
			create_fps_label()
		elif fps_label:
			fps_label.queue_free()
			
func create_fps_label():
	fps_label = FPS_LABEL.instantiate()
	get_tree().root.add_child(fps_label)
