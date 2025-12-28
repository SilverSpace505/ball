extends Node

var seed = 1
var username = 'Unnamed'
var race = false
var startTime = -1

var voidLevel = -100
var time = 0
var running = false
var place = ''

var isReady = false

func _ready() -> void:
	loadData()
	
func _process(delta: float) -> void:
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
