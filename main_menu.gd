extends Control

@export var lobby: LineEdit
@export var username: LineEdit
@export var race: CheckBox

func _ready() -> void:
	lobby.text = str(Global.seed)
	username.text = Global.username
	$options/volSlider.value = Global.userSettings.volume
	$options/volBox.value = Global.userSettings.volume

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
	$AnimationPlayer.play("settingsPressed")
func _on_back_pressed() -> void:
	$AnimationPlayer.play_backwards("settingsPressed")

#volume
func _on_vol_slider_value_changed(value: float) -> void:
	$options/volBox.value = $options/volSlider.value
	Global.userSettings.volume = $options/volBox.value
	Global.saveData()
func _on_vol_box_value_changed(value: float) -> void:
	$options/volSlider.value = $options/volBox.value
	Global.userSettings.volume = $options/volBox.value
	Global.saveData()
