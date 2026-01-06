extends Control

signal settingsClosed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$volBox.value = Global.userSettings.volume
	$volSlider.value = Global.userSettings.volume

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	Sfx.get_node("clickSFX").play()
	$AnimationPlayer.play_backwards("optionsPressed")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
func _on_back_mouse_entered() -> void:
	Sfx.get_node("browseSFX").play()
	


func _on_vol_slider_value_changed(value: float) -> void:
	$volBox.value = $volSlider.value
	Global.userSettings.volume = $volBox.value
	Global.saveData()
	
func _on_vol_box_value_changed(value: float) -> void:
	$volSlider.value = $volBox.value
	Global.userSettings.volume = $volBox.value
	Global.saveData()
pass # Replace with function body.

func _on_vol_slider_music_value_changed(value: float) -> void:
	$volBoxMusic.value = $volSliderMusic.value
	Global.userSettings.musicVol = $volBoxMusic.value
	Global.saveData()
	
func _on_vol_box_music_value_changed(value: float) -> void:
	$volSliderMusic.value = $volBoxMusic.value
	Global.userSettings.musicVol = $volBoxMusic.value
	Global.saveData()

func _on_in_game_back_pressed() -> void:
	$AnimationPlayer.play_backwards("inGameOptions")
	await get_tree().create_timer(1).timeout
	emit_signal("settingsClosed")
