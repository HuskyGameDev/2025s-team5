extends Control

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_parent().get_child(0).get_child(0).get_child(0).show()
			get_parent().get_child(1).show()
			queue_free()


func _on_back_pressed() -> void:
	get_parent().get_child(0).get_child(0).get_child(0).show()
	get_parent().get_child(1).show()
	queue_free()
