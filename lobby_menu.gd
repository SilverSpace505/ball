extends Control

var players = []
var mapLength = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.on_player_joined.connect(_addPlayer)
	#Network.on_player_left.connect(_removePlayer)
	$hostName.text = Network.names[Network.names.keys()[0]] + "'s lobby"
	players = Network.names.values()
	for username in players:
		$playerList.add_item(username)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _addPlayer(id, username):
	$playerList.add_item(username)
	
#func _removePlayer(id):
	#$playerList.remove_item(username)

func _on_start_button_down() -> void:
	Network.client.emit('start')

#Map length change
func _on_length_val_value_changed(value: float) -> void:
	$length/LengthBox.value = $length/LengthVal.value
	Network.options.length = $length/LengthBox.value

func _on_length_box_value_changed(value: float) -> void:
	if($length/LengthBox.value <= 500):
		$length/LengthVal.value = $length/LengthBox.value
	Network.options.length = $length/LengthBox.value
