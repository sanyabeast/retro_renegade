extends AreaTrigger

class_name AreaTriggerLoadLevel
@export var scene_path: String

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	dev.set_label(self, tools.DataContainer.new({
		"load_level_scene_path": "Load Level: %s" % scene_path
	}))
	pass # Replace with function body.

func enter_action():
	dev.logd("AreaTriggerLoadLevel", "entered")
	tools.load_scene(scene_path)
		
