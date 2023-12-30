extends Control

class_name  GameWidget

@export var id: String
@export var interactive: bool = false
@export var show_on_start: bool = true
@export var exclusive: bool = false

var _is_focused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hud.link_hud(self)
	pass # Replace with function body.

func _exit_tree():
	hud.unlink_hud(self)

func focus():
	_is_focused = true
	pass
	
func blur():
	_is_focused = false
	pass
	
func navigate(direction: Vector2):
	pass

func accept():
	pass

func cancel():
	pass
