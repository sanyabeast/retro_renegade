extends Node

class_name DevScript

const TAG: String = "DevScript: "

var debug_print: DebugPrint

var queued_print_screen = {}

func print_screen(topic: String, message: String):
	if debug_print != null:
		debug_print.print(topic, message)
	else:
		queued_print_screen[topic] = message
		
func set_debug_print(node: DebugPrint):
	debug_print = node
	for key in queued_print_screen.keys():
		print_screen(key, queued_print_screen[key])
	queued_print_screen = {}

func _ready():
	print(TAG + "ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
