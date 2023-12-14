extends Node3D

class_name AreaTrigger

@export var allowed_groups: Array = [
	"players"
]

@export var area: Area3D

var current_body: Node3D = null
var is_locked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	area.connect("body_entered", _on_body_entered)
	area.connect("body_exited",_on_body_exited)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(node: Node3D):
	if node == players.current:
		is_locked = true
		current_body = node
		on_entered()
		dev.logd("AreaTrigger", "body entered: %s" % node.name)
	else:
		dev.logd("AreaTrigger", "Trigger is locked by %s" % current_body)

func _on_body_exited(node: Node3D):
	dev.logd("AreaTrigger", "node exited: %s" % node.name)
	is_locked = false
	current_body = null

func on_entered():
	dev.logd("AreaTrigger", "implement on_entered action")
	pass
