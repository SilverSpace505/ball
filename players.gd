extends Node3D

@export var playerInstance: PackedScene

var players: Dictionary[String, NetworkPlayer] = {}

func _ready() -> void:
	Network.on_data.connect(_on_data)
	if Network.connected:
		Network.client.emit('getData')
	
func _on_data(data):
	var id = Network.id
	for player in data:
		if player == id:
			continue
		
		if not player in players and data[player].x != null and data[player].y != null and data[player].z != null and data[player].rx != null:
			players[player] = playerInstance.instantiate()
			players[player].x = data[player].x
			players[player].y = data[player].y
			players[player].z = data[player].z
			players[player].rx = data[player].rx
			players[player].ry = data[player].ry
			players[player].rz = data[player].rz
			add_child(players[player])
		
		if 'x' in data[player]:
			players[player].lx = players[player].x
			players[player].x = data[player].x
		if 'y' in data[player]:
			players[player].ly = players[player].y
			players[player].y = data[player].y
		if 'z' in data[player]:
			players[player].lz = players[player].z
			players[player].z = data[player].z
			
		if 'rx' in data[player]:
			players[player].lrx = players[player].rx
			players[player].rx = data[player].rx
		if 'ry' in data[player]:
			players[player].lry = players[player].ry
			players[player].ry = data[player].ry
		if 'rz' in data[player]:
			players[player].lrz = players[player].rz
			players[player].rz = data[player].rz
	
	for player in players:
		if not player in data or player == id:
			players[player].queue_free()
			players.erase(player)
