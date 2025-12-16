extends Camera3D

@export var mouseSens = 0.002
@onready var cam = $Camera3D
var camera_pitch: float = 0.0 # Vertical rotation accumulator

# move the camera
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Yaw (Left/Right) rotation applied to the parent CharacterBody3D
		rotate_y(-event.relative.x * mouseSens)
		# Pitch (Up/Down) rotation applied to the child head/camera node
		camera_pitch += -event.relative.y * mouseSens
		# Clamp the vertical rotation to prevent the camera from flipping over
		camera_pitch = clampf(deg_to_rad(0), deg_to_rad(-90), deg_to_rad(90))
		rotation.x = camera_pitch
	
