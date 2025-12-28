class_name Player
extends CharacterBody3D

@export var camera: Camera
@export var username: Label3D
@export var mesh: Node3D

@export var speed = 0.05
@export var jumpHeight = 5
@export var gravity = 10
#@export var backSpeed = 5
#@export var minSpeed = 0
#@export var maxSpeed = 50
#@export var turnSpeed = 0.02
#@export var friction = 0.01

#dont need half those variables anymore

var floor = 0.0

#Camera vars
#@export var mouseSens = 1000
func _ready() -> void:
	Network.launch.connect(_launch)
	username.text = Global.username

func _process(delta: float) -> void:
	# get mouse to be used :O
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#elif Input.is_action_pressed("esc"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0:
		velocity.y = 0
	
	#get input axis relative to camera direction
	var wasd = Vector3(Input.get_axis('left', 'right'), 0, Input.get_axis('slow', 'go'))
	
	camera.turn += (wasd.x / 100) * (Vector2(velocity.x, velocity.z).length() / 10) ** 2
	
	wasd *= camera.followQuat
	wasd *= -1
	
	floor -= delta
	
	var addSpeed = clamp(1 + (Vector2(velocity.x, velocity.z).length() / 5) ** 2 / 3, 1, 5)
	
	#add input axis onto velocity
	velocity.x += wasd.x * speed * addSpeed
	velocity.z -= wasd.z * speed * addSpeed
	
	#rotate player by velocity
	mesh.rotate(Vector3(0, 0, 1), -velocity.x / 10 / 5)
	mesh.rotate(Vector3(1, 0, 0), velocity.z / 10 / 5)
	
	#friction
	velocity.x *= 0.99
	velocity.z *= 0.99
	
	var oldVel = velocity
	
	var collision = move_and_collide(velocity * delta)
	
	const bounciness = 0.5
	
	#check for collisions and launch other players
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if 'isNetworkPlayer' in collider:
			var launch = oldVel + Vector3(0, 1, 0) * Vector2(velocity.x, velocity.z).length()
			Network.client.emit('launch', [[collider.id, launch.x, launch.y, launch.z]])
		var change = (1 + bounciness) * velocity.dot(normal) * normal
		if change.length() > 0.1:
			velocity -= change
		if normal.dot(Vector3.UP) > 0.5:
			floor = 0.2
	
	# jump
	if Input.is_action_pressed("jump") && floor > 0:
		velocity.y = jumpHeight
		floor = 0
	
	#void
	if position.y < -100:
		var dif = Vector3(0, 25, 0) - position
		position += dif
		camera.position += dif
		camera.followPos += dif
	
	#networking
	Network.data.x = position.x
	Network.data.y = position.y
	Network.data.z = position.z
	
	Network.data.rx = mesh.rotation.x
	Network.data.ry = mesh.rotation.y
	Network.data.rz = mesh.rotation.z

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			pass
			#i don't think we need this for now
			#rotate(Vector3(0, 1, 0), -event.relative.x / mouseSens)

func _launch(vel):
	velocity += Vector3(vel[0], vel[1], vel[2])
