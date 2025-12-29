extends Control

@export var lobby: LineEdit
@export var username: LineEdit
@export var race: CheckBox

func get_url_parameters() -> Dictionary:
	var params = {}
	
	var js_code = """
	(function() {
	    var params = {};
	    var searchParams = new URLSearchParams(window.location.search);
	    searchParams.forEach(function(value, key) {
	        params[key] = value;
	    });
	    return params;
	})();
	"""
	
	var result = JavaScriptBridge.eval(js_code)
	
	if result != null:
		params = result
	
	return params

func _ready() -> void:
	lobby.text = str(Global.seed)
	username.text = Global.username
	
	if OS.has_feature("web"):
		var url_params = get_url_parameters()
		if url_params.has('lobby'):
			var lobbyf = url_params['lobby']
			var isRace = lobbyf[0] == 'r'
			var lobbyn = lobbyf.slice(1)
			Global.seed = int(lobbyn)
			Global.race = isRace
			race.button_pressed = isRace
			Network.client.emit('join', [str(Global.seed), race.button_pressed])

func _on_play_button_down() -> void:
	Network.client.emit('join', [str(Global.seed), race.button_pressed])
	#get_tree().change_scene_to_file("res://game.tscn")

func _on_lobby_text_changed(new_text: String) -> void:
	if int(new_text):
		Global.seed = int(new_text)

func _on_username_text_changed(new_text: String) -> void:
	Global.username = new_text
	Global.saveData()

func _on_race_toggled(toggled_on: bool) -> void:
	Global.race = toggled_on
