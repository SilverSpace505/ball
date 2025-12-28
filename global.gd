extends Node

var seed = 1
var username = 'Unnamed'
var race = false

func _ready() -> void:
	loadData()

func loadData():
	var config = ConfigFile.new()
	var err = config.load('user://data.cfg')
	if err == OK:
		username = config.get_value('player', 'username', 'Unnamed')
	
func saveData():
	var config = ConfigFile.new()
	config.set_value('player', 'username', username)
	config.save('user://data.cfg')
