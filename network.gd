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
var names = {}

const updateRate = 20

var naccumulator = 0

var fps = 100
var fpsc = 0

signal launch
signal spawn
signal on_connected

signal on_create_offer
signal on_session
signal on_candidate
signal broadcast_data
signal on_dm

signal on_player_joined
signal on_player_left

func get_url_parameters() -> Dictionary:
	var params = {}
	
	var js_code = """
	(function() {
	    var params = {};
	    var searchParams = new URLSearchParams(window.location.search);
	    searchParams.forEach(function(value, key) {
	        params[key] = value;
	    });
	    return JSON.stringify(params);
	})();
	"""
	
	var result = JavaScriptBridge.eval(js_code)
	
	if result != null and result != "":
		var json = JSON.new()
		var error = json.parse(result)
		if error == OK:
			params = json.data
	
	return params

func _ready() -> void:
	print('connecting')
	client.connect_socket()

func _process(delta: float) -> void:
	#increment interpolation and send player data up to server
	fpsc += 1
	naccumulator += delta

func _on_socket_io_socket_connected(_ns: String) -> void:
	#update connection state and request network id
	print('connected!')
	connected = true
	client.emit('getId')
	
	on_connected.emit()
	
	if OS.has_feature("web"):
		var url_params = get_url_parameters()
		if url_params.has('lobby'):
			var lobbyf: String = url_params['lobby']
			var isRace = lobbyf[0] == 'r'
			var lobbyn = lobbyf.substr(1)
			Global.seed = int(lobbyn)
			Global.race = isRace
			Network.client.emit('join', [str(Global.seed), isRace])

func _on_socket_io_event_received(event: String, msg: Variant, _ns: String) -> void:
	if event == 'id':
		#update state with id from server
		id = msg[0]
	elif event == 'joined':
		lobby = msg[0]
		names = msg[1]
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
	elif event == 'createOffer':
		on_create_offer.emit(msg[0])
	elif event == 'session':
		on_session.emit(msg[0], msg[1], msg[2])
	elif event == 'candidate':
		on_candidate.emit(msg[0], msg[1], msg[2], msg[3])
	elif event == 'dm':
		on_dm.emit(msg[0], msg[1])
	elif event == 'playerJoined':
		on_player_joined.emit(msg[0], msg[1])
	elif event == 'playerLeft':
		on_player_left.emit(msg[0])

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
		broadcast_data.emit(data)
		client.emit('data', data)


func _on_timer_2_timeout() -> void:
	fps = fpsc
	fpsc = 0
