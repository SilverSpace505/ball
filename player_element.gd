class_name PlayerElement
extends Control

@export var username: String = 'Unnamed'

@export var place: String = '1st'

@export var time: String = '0'

@export var isReady: int = 0

func _process(_delta: float) -> void:
	$panel/margin/container/username.text = username
	$panel/margin/container/place.text = place
	$panel/margin/container/right/time.text = time
	$panel/margin/container/right/ready.visible = isReady == 1
	$panel/margin/container/right/notready.visible = isReady == 2
