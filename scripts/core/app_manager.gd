extends Node
class_name AppManager

var config: RGameConfig = load("res://resources/config.tres")
var tasks: tools.TaskPlanner = tools.TaskPlanner.new()

func _ready():
	dev.logd("AppManager", "loaded config %s" % config.resource_name)
	dev.print_screen("app-tasks-size", "App tasks list size: %s" % tasks.list.size())
	dev.print_screen("app-tasks-sch-size", "App tasks schedule size: %s" % tasks.schedule_list.keys().size())

func _physics_process(delta):
	tasks.update()
