extends Node3D

@export var playerInstance: PackedScene
@export var playersList: VBoxContainer

@export var playerElement: PackedScene

var players: Dictionary[String, NetworkPlayer] = {}
var playerElements: Dictionary[String, PlayerElement] = {}

func _ready() -> void:
	#if connected already, request all the player data
	Network.on_data.connect(_on_data)
	if Network.connected:
		Network.client.emit('getData')
	
func _on_data(data):
	var id = Network.id
	for player in data:	
		#create a mesh for the players
		if not player in players and 'x' in data[player] and 'y' in data[player] and 'z' in data[player] and 'rx' in data[player] and 'ry' in data[player] and 'rz' in data[player]:
			players[player] = playerInstance.instantiate()
			players[player].id = player
			players[player].x = data[player].x
			players[player].y = data[player].y
			players[player].z = data[player].z
			players[player].rx = data[player].rx
			players[player].ry = data[player].ry
			players[player].rz = data[player].rz
			if player != id:
				add_child(players[player])
			
			playerElements[player] = playerElement.instantiate()
			playersList.add_child(playerElements[player])
		
		#update the position and rotation of the network player
		if player in players:
			if 'username' in data[player]:
				players[player].username = data[player].username
				playerElements[player].username = data[player].username
			
			players[player].lx = players[player].x
			players[player].ly = players[player].y
			players[player].lz = players[player].z
			players[player].lrx = players[player].rx
			players[player].lry = players[player].ry
			players[player].lrz = players[player].rz
		
			if 'x' in data[player]:
				players[player].x = data[player].x
			if 'y' in data[player]:
				players[player].y = data[player].y
			if 'z' in data[player]:
				players[player].z = data[player].z
			if 'rx' in data[player]:
				players[player].rx = data[player].rx
			if 'ry' in data[player]:
				players[player].ry = data[player].ry
			if 'rz' in data[player]:
				players[player].rz = data[player].rz
	
	#delete meshes of disconnected players
	for player in players:
		if not player in data:
			if player != id:
				players[player].queue_free()
			players.erase(player)
			
			playerElements[player].queue_free()
			playerElements.erase(player)
