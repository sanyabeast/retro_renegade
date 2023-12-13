extends Node

class_name DevScript

const TAG: String = "DevScript: "

var _debug_print: DebugPrint
var _debug_labels: DebugLabels

var _queued_print_screen = {}

func logd(tag: String, data):
	print("%s: %s" % [tag, data])
	
func logr(tag: String, data):
	print("%s: [ERROR!] %s" % [tag, data])

func print_screen(topic: String, message: String):
	if _debug_print != null:
		_debug_print.print(topic, message)
	else:
		_queued_print_screen[topic] = message

func set_label(target: Node3D, lines: tools.DataContainer):
	if _debug_labels != null:
		_debug_labels.set_label(target, lines)
	
func remove_label(target: Node3D):
	_debug_labels.remove_label(target)
		
func set_debug_print(node: DebugPrint):
	_debug_print = node
	for key in _queued_print_screen.keys():
		print_screen(key, _queued_print_screen[key])
	_queued_print_screen = {}
	
func set_debug_labels(node: DebugLabels):
	_debug_labels = node

func _ready():
	logd(TAG, "ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
