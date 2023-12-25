extends Node3D

class_name AreaTrigger

@export var allowed_groups: Array = [
	"players"
]

@export var area: Area3D
@export var timeout_before_action: float = 0
@export var cancel_action_on_exit: bool = true

var current_body: Node3D = null
var is_locked: bool = false

signal on_enter(body: Node3D)
signal on_exit(body: Node3D)

# Called when the node enters the scene tree for the first time.
func _ready():
	area.connect("body_entered", _on_body_enters)
	area.connect("body_exited",_on_body_exits)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_enters(node: Node3D):
	if node == players.current:
		is_locked = true
		current_body = node
		on_enter.emit(node)
		
		if timeout_before_action > 0:
			app.tasks.schedule(self, "enter-action", timeout_before_action, enter_action)
		else:
			enter_action()
		dev.logd("AreaTrigger", "body entered: %s" % node.name)
	else:
		dev.logd("AreaTrigger", "Trigger is locked by %s" % current_body)

func _on_body_exits(node: Node3D):
	if timeout_before_action > 0 and cancel_action_on_exit:
		app.tasks.cancel(self, "enter-action")
	
	on_exit.emit(node)
	
	dev.logd("AreaTrigger", "node exited: %s" % node.name)
	is_locked = false
	current_body = null

func enter_action():
	dev.logd("AreaTrigger", "implement enter_action action")
	pass

func exit_action():
	dev.logd("AreaTrigger", "implement enter_action action")
	pass
