extends Node3D

@export var path: Path3D

@export var csgMesh: CSGPolygon3D

@export var staticBody: StaticBody3D

@export var finish: Node3D

func _ready() -> void:
	
	var pos = Vector3()
	var forward = Quaternion()
	var forward2 = Quaternion()
	
	const scalar = 0.1
	
	var vel = Vector3()
	
	path.curve.clear_points()
	path.curve.add_point(Vector3(0, 0, 0))
	
	seed(Global.seed)
	
	for i in range(2000):
		pos += Vector3(0, 0, -1 * scalar) * forward
		path.curve.add_point(pos)
		
		vel.x += randf_range(-0.5, 0.5) * scalar
		vel.y += randf_range(-0.1, 0.1) * scalar
		
		vel.y = clamp(vel.y, -0.5, 0)
		
		vel.x = clamp(vel.x, -2, 2)
		vel.x -= (vel.x ** 3) * scalar
		
		pos.y += vel.y * scalar
		
		forward *= Quaternion(Vector3(0, 1, 0), vel.x * scalar)
		#forward2 *= Quaternion(Vector3(0, 1, 0), vel.y)
		
		#var perp = Vector3(1, 0, 0) * forward2
		#forward *= Quaternion(perp, vel.x)
	
	
	finish.position = pos
	finish.quaternion = forward
	
	var current_path = csgMesh.path_node
	csgMesh.path_node = NodePath("")
	csgMesh.path_node = current_path
