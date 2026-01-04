extends Control

var players = []
var mapLength = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.on_player_joined.connect(_addPlayer)
	$hostName.text = Network.names[Network.names.keys()[0]] + "'s lobby"
	players = Network.names.values()
	for username in players:
		$playerList.add_item(username)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _addPlayer(id, username):
	$playerList.add_item(username)
	
