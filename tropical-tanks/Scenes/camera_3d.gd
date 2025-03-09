extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var speed
	speed = 5
	position.x += speed*delta
	
	if (position.x >= 75):
		position.x = 0
