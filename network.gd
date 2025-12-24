extends Node

@onready var client: SocketIO = $SocketIO

var connected = false

var data = {
	'x': 0.0,
	'y': 0.0,
	'z': 0.0,
	'rx': 0.0,
	'ry': 0.0,
	'rz': 0.0
}

var id = ''

var naccumulator = 0

signal on_data

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

func _on_timer_timeout() -> void:
	if connected:
		client.emit('data', data)
