extends Control

@export var seedInput: LineEdit

func _ready() -> void:
	seedInput.text = str(Global.seed)

func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_seed_text_changed(new_text: String) -> void:
	if int(new_text):
		Global.seed = int(new_text)
