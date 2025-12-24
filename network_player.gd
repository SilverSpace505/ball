class_name NetworkPlayer
extends Node3D

var isNetworkPlayer = true

var id = ''

var x = 0
var lx = 0

var y = 0
var ly = 0

var z = 0
var lz = 0

var rx = 0
var lrx = 0

var ry = 0
var lry = 0

var rz = 0
var lrz = 0

#my little interpolation functions
func lerp(start: float, end: float, multiply: float):
	if multiply > 1:
		multiply = 1
	if multiply < 0:
		multiply = 0
	return start + (end - start) * multiply

func interpVar(current: float, last: float, tickrate: float, accumulator: float):
	return lerp(last, current, accumulator / (1 / tickrate))

func _process(_delta: float) -> void:
	#do some weird interpolation stuff using the accumulator from network.gd
	position.x = interpVar(x, lx, 10, Network.naccumulator)
	position.y = interpVar(y, ly, 10, Network.naccumulator)
	position.z = interpVar(z, lz, 10, Network.naccumulator)
	
	var lastQuat = Quaternion.from_euler(Vector3(lrx, lry, lrz))
	var quat = Quaternion.from_euler(Vector3(rx, ry, rz))
	
	var multiply = Network.naccumulator / (1.0 / 10.0)
	
	quaternion = lastQuat.slerp(quat, multiply)
