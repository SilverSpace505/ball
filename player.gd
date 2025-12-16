extends CharacterBody3D

<<<<<<< HEAD
var speed = 5
var minSpeed = 15
var maxSpeed = 50
var jumpHeight = 100
var turnSpeed = 0.02


=======
@export var speed = 3
@export var minSpeed = 15
@export var maxSpeed = 50
@export var jumpHeight = 100
@export var turnSpeed = 0.02
@export var friction = 0.1

>>>>>>> parent of 748e8b7 (AAAAAAAAAAHHHHHHHH)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var gravity = get_gravity()
	if !is_on_floor():
<<<<<<< HEAD
		velocity = gravity
=======
		velocity += gravity
>>>>>>> parent of 748e8b7 (AAAAAAAAAAHHHHHHHH)
	else:
		gravity = 0
	
	var turnDir = Input.get_axis("right", "left")
	if turnDir:
		$".".rotate(Vector3(0, 1, 0).normalized(), turnDir * turnSpeed)
		
	var direction := Input.get_axis("slow", "go") * basis.z
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		#velocity.x += direction.x * speed
		#velocity.z += direction.z * speed
		velocity.x = lerpf(velocity.x, -direction.x * speed, 0.2)
		velocity.z = lerpf(velocity.z, -direction.z * speed, 0.2)
	else:
<<<<<<< HEAD
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
=======
		velocity.x = move_toward(velocity.x, 0, friction)
		velocity.z = move_toward(velocity.z, 0, friction)
>>>>>>> parent of 748e8b7 (AAAAAAAAAAHHHHHHHH)
	if Input.is_action_pressed("go"):
		speed = lerpf(speed, maxSpeed, 0.002 * speed)
	elif Input.is_action_pressed("slow"):
		speed = lerpf(speed, minSpeed, 0.02 / speed)
	else:
		speed = lerpf(speed, minSpeed, 0.02)
	print_debug(speed)
	print_debug(velocity)
	
	if Input.is_action_just_pressed("jump"):
		velocity.y += jumpHeight
	
	#velocity *= 0.8
	move_and_slide()
