extends Control

class_name DebugPrint

@onready var menu_container: VBoxContainer = $MenuContainer

var labels = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	dev.set_debug_print(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func print(topic: String, message: String):
	if topic not in labels:
		labels[topic] = Label.new()
		labels[topic].add_theme_font_size_override("font_size", 10)
		labels[topic].add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		menu_container.add_child(labels[topic])
		
	var label: Label = labels[topic]
	
	label.text = message
