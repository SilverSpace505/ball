extends CharacterBody3D

var speed = 100
var jumpHeight = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var input_dir := Input.get_vector("left", "right", "go", "slow")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	#if Input.is_action_pressed("go"):
		#pass
	#if Input.is_action_pressed("left"):
		#pass
	#if Input.is_action_pressed("right"):
		#pass
	#if Input.is_action_pressed("slow"):
		#pass
	if Input.is_action_just_pressed("jump"):
		velocity.y = jumpHeight * delta
	
	move_and_slide()
