class_name Camera
extends Camera3D

@export var player: Player

var offset = Vector3()
var followPos = Vector3()
var followQuat = Quaternion()

var turn = 0

#my essential interpolation functions
func lerpn(start, end, multiply, step):
	multiply = 1 - (1 - multiply) ** step
	if multiply > 1:
		multiply = 1
	if multiply < 0:
		multiply = 0
	return start + (end - start) * multiply

func lerp5(start, end, step):
	return lerpn(start, end, 0.5, step)

func _ready() -> void:
	offset = position
	followPos = position

func _process(delta: float) -> void:
	
	turn *= 0.9
	
	#first, draw an imaginary circle around the player, and place the camera target position on it
	var hoverxz = offset.z
	var xzlength = sqrt(
		(followPos.x - player.position.x) ** 2 +
		(followPos.z - player.position.z) ** 2
	)
	var dif = Vector2(player.position.x - followPos.x, player.position.z - followPos.z)
	dif = dif.rotated(turn)
	var nearest = Vector2(
		player.position.x + (-dif.x / xzlength) * hoverxz,
		player.position.z + (-dif.y / xzlength) * hoverxz,
	)
	followPos.x = lerp5(followPos.x, nearest.x, delta * 20 * 10);
	followPos.z = lerp5(followPos.z, nearest.y, delta * 20 * 10);
	
	#extract the rotation along the x and z axis and store it for player movement
	var targetQuaternion = Quaternion()
	var dummy = Transform3D()
	dummy.origin = followPos
	
	var targetPoint = Vector3(
		followPos.x * 2 - player.position.x,
		followPos.y,
		followPos.z * 2 - player.position.z
	)
	
	dummy = dummy.looking_at(targetPoint, Vector3.UP)
	targetQuaternion = dummy.basis.get_rotation_quaternion()
	
	var multiply = 1 - (1 - 0.5) ** (delta * 50 * 10)
	followQuat = followQuat.slerp(targetQuaternion, multiply)
	
	#smoothly move the camera to the target position
	position = Vector3(
		lerp5(position.x, followPos.x, delta * 15),
		lerp5(position.y, player.position.y + offset.y, delta * 15),
		lerp5(position.z, followPos.z, delta * 15),
	)
	
	#smoothly rotate the camera to point at the player
	var dummy2 = Transform3D()
	dummy2.origin = position
	dummy2 = dummy2.looking_at(player.position + Vector3(0, 0, 0), Vector3.UP)
	
	var multiply2 = 1 - (1 - 0.5) ** (delta * 10)
	quaternion = quaternion.slerp(dummy2.basis.get_rotation_quaternion(), multiply2)
