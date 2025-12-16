extends Area3D

var powerType = ["globalSticky", "globalIce", "globalBounce", "lowGrav"]

#func _ready():
	#pass

#func _process(delta):
	#pass

func _on_area_entered(area):
	if area.name == "player": #This line is an untested placeholder, the name probably needs to be something else
		pickup()

func pickup():
	queue_free()
