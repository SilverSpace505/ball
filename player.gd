extends CharacterBody3D

@export var speed = 0
@export var backSpeed = 5
@export var minSpeed = 0
@export var maxSpeed = 50
@export var jumpHeight = 10
@export var gravity = 10
@export var turnSpeed = 0.02
@export var friction = 0.01

var rotationVel = Vector3(0,0,0)
var direction := Input.get_axis("slow", "go") * basis.z
var rotateSpeed = Vector3(direction.x * speed, 0, direction.z * speed)
#Camera vars
@export var mouseSens = 1000
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	rotateSpeed = Vector3(direction.x * speed, 0, direction.z * speed)
	# get mouse to be used :O
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	#print(gravity)
	# gravity
	if is_on_floor() == false:
		#print($camPivot/Camera3D.fov)
		gravity = 1
		gravity = lerpf(gravity, 50, 0.8 * gravity)
		if velocity.y <= -0.00000001:
			$camPivot/Camera3D.fov = lerpf($camPivot/Camera3D.fov, 100, 0.0002 * gravity)
		velocity.y = lerpf(velocity.y, -gravity, 0.002)
	else:
		gravity = 0
	
	# moving script
	var turnDir = Input.get_axis("right", "left")
	if turnDir:
		$".".rotate(Vector3(0, 1, 0).normalized(), turnDir * turnSpeed)
		
	direction = Input.get_axis("slow", "go") * basis.z
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerpf(velocity.x, -direction.x * speed, 0.2)
		velocity.z = lerpf(velocity.z, -direction.z * speed, 0.2)
	else:
		velocity.x = lerpf(velocity.x, 0, 0.01)
		velocity.z = lerpf(velocity.z, 0, 0.01)
	if Input.is_action_just_pressed("go"):
		if speed < 2:
			speed += 2
	if Input.is_action_pressed("go"):
		speed = lerpf(speed, maxSpeed, 0.0002 * speed)
		$camPivot/Camera3D.fov = lerpf($camPivot/Camera3D.fov, 85, 0.0002 * speed)
	elif Input.is_action_just_pressed("slow"):
		if speed < 2:
			speed += 2
	elif Input.is_action_pressed("slow"):
		speed = lerpf(speed, backSpeed, 0.0002 / speed)
		$camPivot/Camera3D.fov = lerpf($camPivot/Camera3D.fov, 75, 0.02)
	else:
		speed = lerpf(speed, minSpeed, 0.2)
		$camPivot/Camera3D.fov = lerpf($camPivot/Camera3D.fov, 75, 0.02)
	#print(speed)
	
	# jump
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = lerpf(velocity.y, jumpHeight, 0.6)
	
	#var dir = Quaternion(Vector3(0,0,0), velocity)
	#var perpendicular = Vector3(1,0,0) * dir
	
	#rotationVel += perpendicular
	#$MeshInstance3D.rotate(-rotationVel, velocity.length())
	#print(rotationVel)
	velocity *= 0.98
	move_and_slide()
	Network.data.x = position.x
	Network.data.y = position.y
	Network.data.z = position.z
	
	Network.data.rx = rotation.x
	Network.data.ry = rotation.y
	Network.data.rz = rotation.z

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x / mouseSens
