extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_vol_slider_value_changed(value: float) -> void:
	$volBox.value = $volSlider.value
	Global.userSettings.volume = $volBox.value
	Global.saveData()
	
func _on_vol_box_value_changed(value: float) -> void:
	$volSlider.value = $volBox.value
	Global.userSettings.volume = $volBox.value
	Global.saveData()
pass # Replace with function body.
