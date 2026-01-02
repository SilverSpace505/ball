extends Node

var seed = 1
var username = 'Unnamed'
var race = true
var startTime = -1

var voidLevel = 0
var time = 0
var running = false
var place = ''

var isReady = false

var lastState = -1

func _ready() -> void:
	loadData()

func _process(_delta: float) -> void:
	var state = 0
	if not running:
		if isReady:
			state = 1
		else:
			state = 2
	if state != lastState and Network.connected and Network.lobby != null:
		Network.client.emit('ready', state)
		lastState = state
	
func _physics_process(delta: float) -> void:
	if running:
		time += delta

func loadData():
	var config = ConfigFile.new()
	var err = config.load('user://data.cfg')
	if err == OK:
		username = config.get_value('player', 'username', 'Unnamed')
	
func saveData():
	var config = ConfigFile.new()
	config.set_value('player', 'username', username)
	config.save('user://data.cfg')
