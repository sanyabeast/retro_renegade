extends Control

class_name  GameWidget

@export var id: String
@export var interactive: bool = false
@export var show_on_start: bool = false
@export var add_on_start: bool = false
@export var input_mode: AppManager.EInputMode = AppManager.EInputMode.NOOP
@export var hide_on_blur: bool = false

@export_subgroup("States")
@export var initial_state: Array[String] = []

@export_subgroup("Misc")
@export var cancel_to_parent: bool = false

var state: HUDManager.HUDStateManager = HUDManager.HUDStateManager.new()
var parent_state: HUDManager.HUDStateManager

var is_focused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	state.widget = self
	_update_parent_state()
	parent_state.link_hud(self)
	state.replace(initial_state)
	
	pass # Replace with function body.

func _exit_tree():
	parent_state.unlink_hud(self)

func handle_focus():
	if not is_focused:
		dev.logd("GameWidget", "widget '%s' RECEIVES focus" % id)
		is_focused = true
		state.reset_focus()
		if input_mode != AppManager.EInputMode.NOOP:
			app.override_input_mode(input_mode)
		
	pass
	
func handle_blur():
	if is_focused:
		dev.logd("GameWidget", "widget '%s' LOSES focus" % id)
		is_focused = false
		state.blur()
		app.stop_input_mode_override()
		
	pass
	
func navigate(direction: Vector2):
	if state.focused_widget != null:
		state.focused_widget.navigate(direction)
	else:
		state.reset_focus()
	pass

func accept():
	if state.focused_widget != null:
		state.focused_widget.accept()
	else:
		state.reset_focus()
	pass

func cancel():
	if state.focused_widget != null:
		state.focused_widget.cancel()
	else:
		if cancel_to_parent:
			parent_state.blur()
		else:
			hud.blur()
	pass

func display():
	show()
	
func conceal():
	hide()

func _update_parent_state():
	var parent = get_parent()
	while parent != null:
		if parent is GameWidget:
			parent_state = parent.state
			dev.logd("GameWidget", "widget '%s' will be linked to WIDGET '%s'" % [id, parent.id])
			break;
		parent = parent.get_parent()
		
	if parent_state == null:
		parent_state = hud.state
		dev.logd("GameWidget", "widget '%s' will be linked to ROOT" % [id])
