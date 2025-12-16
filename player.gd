extends CharacterBody3D

var speed = 1
var maxSpeed = 5
var jumpHeight = 100
var turnSpeed = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var gravity = get_gravity()
	if !is_on_floor():
		velocity = gravity
	else:
		gravity = 0
	
	var turnDir = Input.get_axis("left", "right")
	if turnDir:
		$".".transform.rotation.y += turnDir * turnSpeed
		
	var direction := Input.get_axis("slow", "go")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		#velocity.x += direction.x * speed
		#velocity.z += direction.z * speed
		velocity.x = lerpf(velocity.x, direction * speed, 0.2)
		velocity.z = lerpf(velocity.z, direction * speed, 0.02)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	if Input.is_action_pressed("go"):
		speed = lerpf(speed, maxSpeed, 0.002 * speed)
	elif Input.is_action_pressed("slow"):
		speed = lerpf(speed, 1, 0.02 / speed)
	else:
		speed = lerpf(speed, 1, 0.02)
	print_debug(speed)
	print_debug(velocity)
	
	if Input.is_action_just_pressed("jump"):
		velocity.y += jumpHeight
	
	velocity *= 0.8
	move_and_slide()
