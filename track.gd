extends Node3D

@export var path: Path3D

@export var csgMesh: CSGPolygon3D

@export var finish: Node3D

@export var island: PackedScene
@export var islands: Node3D

var trackPoints: PackedVector2Array

func _on_seed():
	var points = trackPoints
	for i in range(len(points)):
		if points[i].x < 0:
			points[i] = points[i] - Vector2(Network.options.trackSize - 1, 0)
		if points[i].x > 0:
			points[i] = points[i] + Vector2(Network.options.trackSize - 1, 0)
	csgMesh.polygon = points
	
	var pos = Vector3()
	var forward = Quaternion()
		
	const scalar = 0.1
	
	var tvel = Vector3(0, -0.2, 0)
	var vel = tvel
	
	path.curve.clear_points()
	path.curve.add_point(Vector3(0, 0, 0))
	
	seed(Network.options.seed)
	
	var allPositions = []
	
	var positions = []
	var quaternions = []
	
	for i in range(Network.options.length * 100):
		
		pos += Vector3(0, 0, -1 * scalar) * forward
		path.curve.add_point(pos)
		
		if i % int(2 / scalar) == 0:
			allPositions.append(pos)
		
		if i >= Network.options.length * 100 - 5:
			positions.append(pos)
			quaternions.append(forward)
		
		var turnFactor = Network.options.turning
		if turnFactor < 0:
			turnFactor = 1 / abs(turnFactor)
		tvel.x += randf_range(-0.5, 0.5) * scalar * turnFactor
		tvel.y += randf_range(-0.1, 0.1) * scalar * turnFactor
		
		tvel.y = clamp(tvel.y, -0.5, 0)
		
		tvel.x -= (tvel.x ** 3) * scalar * 10 / turnFactor
		tvel.x = clamp(tvel.x, -2, 2)
		
		vel = vel.lerp(tvel, 0.025)
		
		pos.y += vel.y * scalar
		
		forward *= Quaternion(Vector3(0, 1, 0), vel.x * scalar / Network.options.trackSize) 
		
		Global.voidLevel = min(Global.voidLevel, pos.y - 5)
			
		#forward2 *= Quaternion(Vector3(0, 1, 0), vel.y)
		
		#var perp = Vector3(1, 0, 0) * forward2
		#forward *= Quaternion(perp, vel.x)
		
	finish.position = positions[0] - $Path3D.global_position
	
	for island2 in islands.get_children():
		island2.queue_free()
	
	#spawn islands
	for pos1 in allPositions:
		if randf() > 0.9:
			var offset = Vector3(0, 0, 0)
			for try in range(10):
				offset = Vector3(randf_range(-1, 1), randf_range(0, 0.25), randf_range(-1, 1)).normalized() * randf_range(10, 20)
				var again = false
				for pos2 in allPositions:
					if (pos1 + offset).distance_to(pos2) < 10:
						again = true
				if not again:
					break
			
			var newIsland = island.instantiate()
			newIsland.position = pos1 + offset
			newIsland.noiseSeed = randi()
			newIsland.start_generate()
			islands.add_child(newIsland)
		
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

func _ready() -> void:
	Network.on_seed.connect(_on_seed)
	
	trackPoints = csgMesh.polygon
	
	_on_seed()
