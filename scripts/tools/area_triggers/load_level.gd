extends AreaTrigger

class_name AreaTriggerLoadLevel
@export var scene_path: String

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	pass # Replace with function body.

func on_entered():
	print("entered")
	tools.load_scene(scene_path)
