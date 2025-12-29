extends Node3D

@export var path: Path3D

@export var csgMesh: CSGPolygon3D

@export var staticBody: StaticBody3D

@export var finish: Node3D

func _ready() -> void:
	
	var pos = Vector3()
	var forward = Quaternion()
	
	var totalx = 0
	
	const scalar = 0.1
	
	var vel = Vector3(0, -0.2, 0)
	
	path.curve.clear_points()
	path.curve.add_point(Vector3(0, 0, 0))
	
	seed(Global.seed)
	
	var positions = []
	var quaternions = []
	
	for i in range(2000):
		
		pos += Vector3(0, 0, -1 * scalar) * forward
		path.curve.add_point(pos)
		
		if i >= 2000 - 5:
			positions.append(pos)
			quaternions.append(forward)
		
		vel.x += randf_range(-0.5, 0.5) * scalar
		vel.y += randf_range(-0.1, 0.1) * scalar
		
		vel.y = clamp(vel.y, -0.5, 0)
		
		vel.x -= (vel.x ** 3) * scalar * 10
		vel.x = clamp(vel.x, -2, 2)
		
		pos.y += vel.y * scalar
		
		forward *= Quaternion(Vector3(0, 1, 0), vel.x * scalar)
		totalx += vel.x * scalar
		
		Global.voidLevel = min(Global.voidLevel, pos.y - 5)
		#forward2 *= Quaternion(Vector3(0, 1, 0), vel.y)
		
		#var perp = Vector3(1, 0, 0) * forward2
		#forward *= Quaternion(perp, vel.x)
	
	totalx -= vel.x * scalar
	
	finish.position = positions[0] - $Path3D.global_position
		
	# Calculate the actual forward direction from the last quaternion
	var track_forward = Vector3(0, 0, -1) * quaternions[0]
	var track_up = Vector3(0, 1, 0) * quaternions[0]
	
	# Create a basis from the track direction and set it
	var finish_basis = Basis()
	finish_basis.z = -track_forward.normalized()  # Forward is -Z in Godot
	finish_basis.y = track_up.normalized()
	finish_basis.x = finish_basis.y.cross(finish_basis.z).normalized()
	finish_basis = finish_basis.orthonormalized()
	
	finish.basis = finish_basis
	#finish.quaternion = quaternions[len(quaternions) - 1]
	#finish.rotation = $Path3D.global_rotation * finishQ
	
	var current_path = csgMesh.path_node
	csgMesh.path_node = NodePath("")
	csgMesh.path_node = current_path
