extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


var water_speed = 1
var time = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	position.x += cos(time * 4) * water_speed * delta
	position.z += sin(time * 1.5) * water_speed * delta * 0.2
	position.y += sin(time * 40) * water_speed * delta * 0.1
	time += delta / 30
	
