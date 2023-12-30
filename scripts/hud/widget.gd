extends Control

class_name  GameWidget

@export var id: String
@export var interactive: bool = false
@export var show_on_start: bool = false
@export var add_on_start: bool = false

@export var use_local_state: bool = false
var state: HUDManager.HUDStateManager = HUDManager.HUDStateManager.new()
var root_state: HUDManager.HUDStateManager

var is_focused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_root_state()
	root_state.link_hud(self)
	pass # Replace with function body.

func _exit_tree():
	hud.unlink_hud(self)

func focus():
	is_focused = true
	state._find_next_focused_item()
	pass
	
func blur():
	is_focused = false
	pass
	
func navigate(direction: Vector2):
	if use_local_state and state.focused_widget:
		state.focused_widget.navigate(direction)
	pass

func accept():
	if use_local_state and state.focused_widget:
		state.focused_widget.accept()
	else:
		state.reset_focused()
	pass

func cancel():
	if use_local_state and state.focused_widget:
		state.focused_widget.cancel()
	else:
		root_state.unset_focused()
	pass

func _update_root_state():
	var parent = get_parent()
	while parent != null:
		if parent is GameWidget and parent.use_local_state:
			root_state = parent.state
			break;
		parent = parent.get_parent()
		
	if root_state == null:
		root_state = hud.state
	
	print(root_state)
