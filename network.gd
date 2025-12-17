extends Node

@onready var client: SocketIO = $SocketIO

var connected = false

var data = {
	'x': 0,
	'y': 0,
	'z': 0,
	'rx': 0,
	'ry': 0,
	'rz': 0
}

var id = ''

var naccumulator = 0

signal on_data

func _ready() -> void:
	print('connecting')
	client.connect_socket()

func _process(delta: float) -> void:
	naccumulator += delta
	if connected:
		client.emit('data', data)

func _on_socket_io_socket_connected(_ns: String) -> void:
	print('connected!')
	connected = true
	client.emit('getId')

func _on_socket_io_event_received(event: String, msg: Variant, _ns: String) -> void:
	if event == 'data':
		naccumulator = 0
		on_data.emit(msg[0])
	elif event == 'id':
		id = msg[0]
