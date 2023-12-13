extends Node
class_name AppManager

var config: RGameConfig = load("res://resources/config.tres")

func _ready():
	dev.logd("AppManager", "loaded config %s" % config.resource_name)
