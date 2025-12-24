class_name Player
extends CharacterBody3D

@export var camera: Camera

@export var speed = 0.05
@export var jumpHeight = 7
@export var gravity = 10
#@export var backSpeed = 5
#@export var minSpeed = 0
#@export var maxSpeed = 50
#@export var turnSpeed = 0.02
#@export var friction = 0.01

#dont need half those variables anymore

#Camera vars
#@export var mouseSens = 1000
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# get mouse to be used :O
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	#get input axis relative to camera direction
	var wasd = Vector3(Input.get_axis('left', 'right'), 0, Input.get_axis('slow', 'go'))
	wasd *= camera.followQuat
	wasd *= -1
	
	#add input axis onto velocity
	velocity.x += wasd.x * speed
	velocity.z -= wasd.z * speed
	
	#rotate player by velocity
	rotate(Vector3(0, 0, 1), -velocity.x / 10 / 5)
	rotate(Vector3(1, 0, 0), velocity.z / 10 / 5)
	
	# jump
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = lerpf(velocity.y, jumpHeight, 0.6)
	
	#friction
	velocity.x *= 0.99
	velocity.z *= 0.99
	
	move_and_slide()
	
	#void
	if position.y < -10:
		var dif = Vector3(0, 10, 0) - position
		position += dif
		camera.position += dif
		camera.followPos += dif
	
	#networking
	Network.data.x = position.x
	Network.data.y = position.y
	Network.data.z = position.z
	
	Network.data.rx = rotation.x
	Network.data.ry = rotation.y
	Network.data.rz = rotation.z

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			pass
			#i don't think we need this for now
			#rotate(Vector3(0, 1, 0), -event.relative.x / mouseSens)
