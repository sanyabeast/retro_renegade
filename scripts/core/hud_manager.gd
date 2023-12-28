extends Node

class_name HUDManager

var fps_base: FPSBaseHUD


# Called when the node enters the scene tree for the first time.
func _ready():
	var control: Control = Control.new()
	tools.get_scene().add_child(control)
	var label: Label = Label.new()
	label.text = "asdasdasd"
	control.add_child(label)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
