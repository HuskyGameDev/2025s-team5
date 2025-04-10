extends Control

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			close()

func _on_back_pressed() -> void:
	close()

#var parent_menu
func close():
	#if parent_menu.has_method("popup_closed"):
		#parent_menu.popup_closed()
	get_parent().get_child(0).show()
	queue_free()
