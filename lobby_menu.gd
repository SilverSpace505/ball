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

func _removePlayer(id):
	$playerList.remove_item(Network.names.keys().find(id))

func _on_start_button_down() -> void:
	Network.client.emit('start')

#Map length change
func _on_length_val_value_changed(value: float) -> void:
	$track/length/lengthBox.value = $track/length/lengthVal.value
	Network.options.length = $track/length/lengthBox.value

func _on_length_box_value_changed(value: float) -> void:
	if($track/length/lengthBox.value <= 500):
		$track/length/lengthVal.value = $track/length/lengthBox.value
	Network.options.length = $track/length/lengthBox.value

#turning amount change
func _on_turning_val_value_changed(value: float) -> void:
	$track/turning/turningBox.value = $track/turning/turningVal.value
	Network.options.turning = $track/length/turningBox.value

func _on_turning_box_value_changed(value: float) -> void:
	$track/turning/turningVal.value = $track/turning/turningBox.value
	Network.options.turning = $track/length/turningBox.value
