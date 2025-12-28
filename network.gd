extends Node

@onready var client: SocketIO = $SocketIO

var connected = false

var data = {
	'x': 0.0,
	'y': 0.0,
	'z': 0.0,
	'rx': 0.0,
	'ry': 0.0,
	'rz': 0.0,
	'username': 'Unnamed',
	'time': 0,
	'ready': 0,
	'place': ''
}

var id = ''
var lobby = null

var naccumulator = 0

signal on_data
signal launch
signal spawn

func _ready() -> void:
	print('connecting')
	client.connect_socket()

func _process(delta: float) -> void:
	#increment interpolation and send player data up to server
	naccumulator += delta

func _on_socket_io_socket_connected(_ns: String) -> void:
	#update connection state and request network id
	print('connected!')
	connected = true
	client.emit('getId')

func _on_socket_io_event_received(event: String, msg: Variant, _ns: String) -> void:
	if event == 'data':
		#reset interpolation and let players.gd handle the global players data
		naccumulator = 0
		on_data.emit(msg[0])
	elif event == 'id':
		#update state with id from server
		id = msg[0]
	elif event == 'launch':
		launch.emit(msg[0])
	elif event == 'joined':
		lobby = msg[0]
		get_tree().change_scene_to_file("res://game.tscn")
	elif event == 'start':
		Global.startTime = msg[0]
		Global.time = 0
		Global.place = ''
		spawn.emit(msg[1])
	elif event == 'cancelStart':
		Global.startTime = -1
	elif event == 'place':
		Global.place = msg[0]

func _on_timer_timeout() -> void:
	if connected and lobby != null:
		data.username = Global.username
		data.time = Global.time
		var isReady = 0
		if not Global.running:
			if Global.isReady:
				isReady = 1
			else:
				isReady = 2
		data.ready = isReady
		data.place = Global.place
		client.emit('data', data)
