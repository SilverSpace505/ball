extends Control

@export var lobby: LineEdit
@export var username: LineEdit
@export var race: CheckBox

func _ready() -> void:
	lobby.text = str(Global.seed)
	username.text = Global.username

func _on_play_button_down() -> void:
	$AnimationPlayer.play("sceneTransition")
	await get_tree().create_timer(0.5).timeout
	Network.client.emit('join', [str(Global.seed), race.button_pressed, Global.username])
	#get_tree().change_scene_to_file("res://game.tscn")

func _on_lobby_text_changed(new_text: String) -> void:
	if int(new_text):
		Global.seed = int(new_text)

func _on_username_text_changed(new_text: String) -> void:
	Global.username = new_text
	Global.saveData()

func _on_race_toggled(toggled_on: bool) -> void:
	Global.race = toggled_on

#user settings tab
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://options_menu.tscn")
func _on_back_pressed() -> void:
	$AnimationPlayer.play_backwards("settingsPressed")

#volume
