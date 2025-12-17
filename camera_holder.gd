extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = $"../playerBetter".position
	
	if Input.is_action_pressed("go"):
		$Camera3D.fov = lerpf($Camera3D.fov, 85, 0.002)
	elif Input.is_action_pressed("slow"):
		$Camera3D.fov = lerpf($Camera3D.fov, 75, 0.02)
	else:
		$Camera3D.fov = lerpf($Camera3D.fov, 75, 0.02)
