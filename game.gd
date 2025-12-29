extends Node3D

@export var player: Player
@export var camera: Camera
@export var start: Label

func _ready() -> void:
	Global.running = not Global.race
	Global.isReady = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('ready'):
		if Global.race:
			if not Global.running:
				Global.isReady = not Global.isReady
		elif not Global.running:
			Global.running = true
			Global.time = 0
			player.reset()
	
	var unix_timestamp_ms = Time.get_unix_time_from_system() * 1000
	if unix_timestamp_ms < Global.startTime:
		start.text = str(int(min(3, ceil((Global.startTime - unix_timestamp_ms) / 1000))))
	else:
		start.text = ''
	
	if Global.startTime != -1 and unix_timestamp_ms >= Global.startTime:
		Global.startTime = -1
		Global.time = 0
		Global.running = true
		Global.isReady = false
