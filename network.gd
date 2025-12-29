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
	naccumulator += delta

func _on_socket_io_socket_connected(_ns: String) -> void:
	#update connection state and request network id
	print('connected!')
	connected = true
	client.emit('getId')
	
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
