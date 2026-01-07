class_name Player
extends CharacterBody3D

@export var camera: Camera

@export var username: Label3D
@export var mesh: Node3D
@export var core: Node3D
@export var scaleNode: Node3D

@export var speed = Network.options.speed / 100
@export var jumpHeight = 3
@export var gravity = 10
#@export var backSpeed = 5
#@export var minSpeed = 0
#@export var maxSpeed = 50
#@export var turnSpeed = 0.02
#@export var friction = 0.01

#dont need half those variables anymore

var floort = 0.0
var bounceFactor = 1.0
var moveSpeed = 0.0

var scaleVel = Vector3()
var lastPosition = Vector3()

#Camera vars
#@export var mouseSens = 1000
func _ready() -> void:
	Network.launch.connect(_launch)
	Network.spawn.connect(_spawn)
	username.text = Global.username
	lastPosition = position
	
func tp(pos):
	var dif = pos - position
	position += dif
	lastPosition += dif
	core.global_position = global_position
	camera.position += dif
	camera.followPos += dif

func reset():
	position = Vector3()
	lastPosition = Vector3()
	velocity = Vector3()
	camera.position = camera.offset
	camera.look_at(position + Vector3(0, 0.2, 0))
	camera.followPos = camera.offset + position
	camera.followQuat = camera.quaternion

func _physics_process(delta: float) -> void:
	# get mouse to be used :O
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#elif Input.is_action_pressed("esc"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	lastPosition = global_position
	
	moveSpeed = lerp(moveSpeed, Vector2(velocity.x, velocity.z).length() / 5, delta * 2)
	
	if Global.running:
		velocity.y -= gravity * delta
	
	#get input axis relative to camera direction
	var wasd = Vector3(Input.get_axis('left', 'right'), 0, Input.get_axis('slow', 'go')).normalized()
	camera.turn += (wasd.x / 100) * min(moveSpeed, 3)
	
	wasd *= camera.followQuat
	wasd *= -1
	
	if not Global.running:
		wasd *= 0
	
	floort -= delta
	
	var addSpeed = clamp(1 + moveSpeed ** 2 / 3, 1, 10)
	
	#add input axis onto velocity
	velocity.x += wasd.x * speed * addSpeed
	velocity.z -= wasd.z * speed * addSpeed
	
	#friction
	velocity.x *= 0.99
	velocity.z *= 0.99
	
	if not Global.running:
		velocity *= 0.99
	
	var oldVel = velocity
	
	var collision = move_and_collide(velocity * delta)
	
	const bounciness = 0.3
	
	#check for collisions and launch other players
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if 'isNetworkPlayer' in collider:
			var launch = oldVel + Vector3(0, 0.2, 0) * Vector2(velocity.x, velocity.z).length()
			if collider.connected:
				collider.send_msg('launch', [launch.x, launch.y, launch.z], true)
			#Network.client.emit('launch', [[collider.id, launch.x, launch.y, launch.z]])
		var change = (1 + bounciness * bounceFactor) * velocity.dot(normal) * normal
		if change.length() > 0.1:
			velocity -= change
		bounceFactor = 1
		if normal.dot(Vector3.UP) > 0.5:
			floort = 0.2
		
		#scaleVel += change.cross(Vector3.UP)
	
	# jump
	if Network.options.jumps == true:
		if Input.is_action_pressed("jump") && floort > 0:
			velocity.y = jumpHeight
			floort = 0
	
	#void
	if position.y < Global.voidLevel:
		tp(Vector3(0, 1, 0))
		bounceFactor = 0
	
	#networking
	Network.data.x = position.x
	Network.data.y = position.y
	Network.data.z = position.z
	
	Network.data.rx = mesh.rotation.x
	Network.data.ry = mesh.rotation.y
	Network.data.rz = mesh.rotation.z
	
func _process(delta: float) -> void:
	#rotate player by velocity
	mesh.rotate(Vector3(0, 0, 1), -velocity.x * delta * 2)
	mesh.rotate(Vector3(1, 0, 0), velocity.z * delta * 2)
	
	var alpha = Engine.get_physics_interpolation_fraction()
	core.global_position = core.global_position.lerp(lastPosition.lerp(global_position, alpha), clamp(delta * 50, 0, 1))
	
	#scaleVel += (Vector3.ONE - scaleNode.scale) / 10
	#scaleNode.scale += scaleVel
	#var squash = clamp(velocity.length() * 0.3, 0, 0.5)
	#var dir = velocity.normalized()
	#var target_scale = Vector3.ONE
	#if velocity.length() > 0.01:
		#var right = dir.cross(Vector3.UP).normalized()
		#target_scale = Vector3.ONE - dir * squash + right * squash * 0.5
	#scaleNode.scale = scaleNode.scale.lerp(target_scale, delta * 10)
	
	#core.global_position = core.global_position.lerp(global_position, clamp(delta * 20, 0, 1))
	if Network.fps < 100:
		core.global_position = global_position
	
	$core/Label3D.fixed_size = camera.global_position.distance_to($core/Label3D.global_position) > 1

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			pass
			#i don't think we need this for now
			#rotate(Vector3(0, 1, 0), -event.relative.x / mouseSens)

func _launch(vel):
	velocity += Vector3(vel[0], vel[1], vel[2])

func _spawn(index):
	position = Vector3(index * 0.25, 0, 0)
	velocity = Vector3()
	core.global_position = global_position
	
	camera.followPos = camera.offset + position
	camera.followQuat = Quaternion()
	
	#camera.position = camera.offset + position
	#camera.look_at(position + Vector3(0, 0.2, 0))
	#camera.followPos = camera.offset + position
	#camera.followQuat = camera.quaternion
