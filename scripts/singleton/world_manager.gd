extends Node

class_name WorldManager

var level: GameLevel

func set_level(_level: GameLevel):
	print("World: level set to: %s" % _level.name)
	level = _level
	
func unset_level(_level: GameLevel):
	if level == _level:
		print("World: level unset: %s" % _level.name)
		level = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
