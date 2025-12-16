extends Path3D

@export var track_width: float = 2.0
@export var track_segments: int = 50
@export var track_thickness: float = 0.2

func _ready():
	generate_track()

func generate_track():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var path_length = curve.get_baked_length()
	var segment_length = path_length / track_segments
	
	# Generate vertices along the path
	for i in range(track_segments + 1):
		var offset = i * segment_length
		var pos = curve.sample_baked(offset)
		var forward = curve.sample_baked_with_rotation(offset, true).basis.z
		var right = forward.cross(Vector3.UP).normalized()
		
		# Create track width
		var left_point = pos - right * (track_width / 2.0)
		var right_point = pos + right * (track_width / 2.0)
		
		st.add_vertex(left_point)
		st.add_vertex(right_point)
	
	# Create triangles
	for i in range(track_segments):
		var base = i * 2
		# First triangle
		st.add_index(base)
		st.add_index(base + 2)
		st.add_index(base + 1)
		# Second triangle
		st.add_index(base + 1)
		st.add_index(base + 2)
		st.add_index(base + 3)
	
	st.generate_normals()
	var mesh = st.commit()
	
	# Create the visual mesh
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
	
	# Create collision
	var static_body = StaticBody3D.new()
	add_child(static_body)
	
	var collision = CollisionShape3D.new()
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(mesh.get_faces())
	collision.shape = shape
	
	static_body.add_child(collision)
	
	
