class_name PlayerElement
extends Control

@export var username: String = 'Unnamed'

@export var place: String = ''

@export var time: String = '0'

@export var isReady: int = 2

@export var connecting: bool = true

@export var latency: String = ''

@export var progress: String = ''

@export var distance: String = ''

func _process(_delta: float) -> void:
	$panel/margin/container/username.text = username
	$panel/margin/container/place.text = place
	$panel/margin/container/right/time.text = time
	$panel/margin/container/right/ready.visible = isReady == 1
	$panel/margin/container/right/notready.visible = isReady == 2
	$panel/margin/container/right/connecting.visible = connecting
	$panel/margin/container/right/latency.text = latency
	$panel/margin/container/right/progress.text = progress
	$panel/margin/container/right/distance.text = distance
