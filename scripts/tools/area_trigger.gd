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
	if not is_locked:
		for group_name in allowed_groups:
			if node.is_in_group(group_name):  # Assuming the player is in a group named "Player"
				is_locked = true
				current_body = node
				on_entered()
				print("AreaTrigger: body entered: %s" % node.name)
				break
	else:
		print("Trigger is locked by %s" % current_body)

func _on_body_exited(node: Node3D):
	print("AreaTrigger: node exited: %s" % node.name)
	is_locked = false
	current_body = null

func on_entered():
	print("AreaTrigger: implement on_entered action")
	pass
