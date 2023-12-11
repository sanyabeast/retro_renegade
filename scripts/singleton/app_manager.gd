extends Node
class_name AppManager

var config: RGameConfig = load("res://resources/config.tres")

func _ready():
	print("AppManager: loaded config %s" % config.resource_name)
