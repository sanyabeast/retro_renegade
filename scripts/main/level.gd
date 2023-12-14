extends Node3D

class_name GameLevel

@export var settings: RGameLevel

# Called when the node enters the scene tree for the first time.
func _ready():
	world.set_level(self)
	pass # Replace with function body.

func _exit_tree():
	world.unset_level(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
