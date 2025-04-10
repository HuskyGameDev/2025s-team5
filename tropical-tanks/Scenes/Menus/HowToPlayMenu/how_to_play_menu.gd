extends Control

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			close()

func _on_back_pressed() -> void:
	close()

func close() -> void:
	get_parent().get_child(0).show()
	queue_free()
