class_name Players
extends Node3D

@export var playerInstance: PackedScene
@export var playersList: VBoxContainer

@export var playerElement: PackedScene

@export var player: Player

var players: Dictionary[String, NetworkPlayer] = {}
var playerElements: Dictionary[String, PlayerElement] = {}
var inRace = false

var center = Vector3()
var minp = Vector3()
var maxp = Vector3()
var length = 0

func _ready() -> void:
	#if connected already, request all the player data
	Network.on_data.connect(_on_data)
	if Network.connected:
		Network.client.emit('getData')

func _process(delta: float) -> void:
	var currentCenter = Vector3()
	var racingPlayers = 0
	minp = Vector3(INF, INF, INF)
	maxp = Vector3(-INF, -INF, -INF)
	if Network.id in playerElements:
		players[Network.id].itime = Global.time
		playerElements[Network.id].place = Global.place
		playerElements[Network.id].time = str(round(Global.time * 100) / 100)
		playerElements[Network.id].isReady = 0
		if not Global.running:
			if Global.isReady:
				playerElements[Network.id].isReady = 1
			else:
				playerElements[Network.id].isReady = 2
	
	for player2 in players:
		if playerElements[player2].isReady == 0:
			racingPlayers += 1
			currentCenter += players[player2].position
			minp = Vector3(
				min(minp.x, players[player2].position.x),
				min(minp.y, players[player2].position.y),
				min(minp.z, players[player2].position.z)
			)
			maxp = Vector3(
				max(maxp.x, players[player2].position.x),
				max(maxp.y, players[player2].position.y),
				max(maxp.z, players[player2].position.z)
			)
		
		players[player2].get_node('CollisionShape3D').disabled = not Global.running
		if player2 == Network.id:
			continue
		if player2 in playerElements:
			playerElements[player2].time = str(round(players[player2].itime * 100) / 100)
			if playerElements[player2].time == '0.0':
				playerElements[player2].time = '0'
	
	if racingPlayers > 0:
		currentCenter /= racingPlayers
	print(racingPlayers)
	if Global.running or not Global.race:
		currentCenter = player.position
	center = center.lerp(currentCenter, clamp(delta * 10, 0, 1))
	length = (maxp - minp).length()
	
	var children = playersList.get_children()
	children.sort_custom(func(a, b):
		var aplace = a.place != ''
		var bplace = b.place != ''
		
		if aplace != bplace:
			return aplace
		
		return float(a.time) < float(b.time)
	)
	
	for i in range(children.size()):
		playersList.move_child(children[i], i)
	
func _on_data(data):
	inRace = false
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
			players[player].get_node('CollisionShape3D').disabled = not Global.running
			if player != id:
				add_child(players[player])
			
			playerElements[player] = playerElement.instantiate()
			playersList.add_child(playerElements[player])
		
		#update the position and rotation of the network player
		if player in players:
			if 'username' in data[player]:
				players[player].username = data[player].username
				playerElements[player].username = data[player].username
			if 'ready' in data[player]:
				playerElements[player].isReady = data[player].ready
			if 'place' in data[player] and id != player:
				playerElements[player].place = data[player].place
			
			players[player].lx = players[player].x
			players[player].ly = players[player].y
			players[player].lz = players[player].z
			players[player].lrx = players[player].rx
			players[player].lry = players[player].ry
			players[player].lrz = players[player].rz
			players[player].ltime = players[player].time
		
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
			if 'time' in data[player]:
				players[player].time = data[player].time
		
			if playerElements[player].isReady == 0:
				inRace = Global.race
	
	#delete meshes of disconnected players
	for player in players:
		if not player in data:
			if player != id:
				players[player].queue_free()
			players.erase(player)
			
			playerElements[player].queue_free()
			playerElements.erase(player)
