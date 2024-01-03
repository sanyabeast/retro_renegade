extends Node

class_name HUDManager

class HUDStateManager:
	var widgets: Dictionary = {}
	var focused_widget: GameWidget
	var current: Array[String] = []
	var history: Array[Array]
	var widget: GameWidget
	
	func push(state: Array[String]):
		focused_widget = null
		if current.size() > 0:
			history.push_back(current.duplicate())
		_set_state(state)
		pass	
		
	func pop():
		if history.size() > 0:
			history.pop_back()
			replace(history.back())

	func replace(state: Array[String]):
		_set_state(state)

	func _set_state(state: Array[String]):
		dev.logd("HUDStateManager", "entering state: %s" % (", ".join(state)))
		for item in current:
			if not state.has(item):
				hide(item)
				
		current = []
		
		for item in state:
			add(item)	
		
		reset_focus()
		
	func reset_focus():
		unset_focus()
		
		for item in current:
			if not widgets.has(item):
				dev.logr("GameWidget", "failed to process FOCUS for '%s' - widget not exist (yet?) " % item)
				continue
				
			if widgets[item].interactive:
				focused_widget = widgets[item]
				focused_widget.handle_focus()
				break
	
	func unset_focus():
		if focused_widget != null:
			focused_widget.handle_blur()
			focused_widget = null
			
	func exists(id: String):
		return widgets.has(id)
		
	func is_present(id: String):
		return current.has(id)
		
	func is_visible(id: String):
		return widgets[id].visible
		
	func show(id: String):
		if widgets.has(id):
			widgets[id].display()
			dev.logd("HUDStateManager", "showing '%s'" % id)
			if widgets[id].interactive:
				hud.focus(widgets[id])
		else:
			dev.logd("HUDStateManager", "Failed to SHOW '%s' - widget does not linked" % id)
			
	func hide(id: String):
		if widgets.has(id):
			widgets[id].conceal()
			dev.logd("HUDStateManager", "hiding '%s'" % id)
			
			if focused_widget == widgets[id]:
				reset_focus()
		else:
			dev.logd("HUDStateManager", "Failed to HIDE '%s' - widget does not linked" % id)
	func add(id: String):
		if not current.has(id):
			current.append(id)
		show(id)
		
	func remove(id: String):
		if current.has(id):
				current.remove_at(current.find(id))
		hide(id)
		
	func link_hud(hud: GameWidget):
		assert(hud.id != "", "GameWidget ID must be not empty string  (%s)" % hud.name)
		widgets[hud.id] = hud 
		
		if hud.add_on_start:
			add(hud.id)
		elif hud.show_on_start:
			show(hud.id)
		else:
			hide(hud.id)
			
		if current.has(hud.id):
			show(hud.id)

	func unlink_hud(hud: GameWidget):
		if widgets.has(hud.id) and widgets[hud.id] == hud:
			widgets.erase(hud.id)

	func reset():
		history = []
		widgets = {}
		if focused_widget != null:
			focused_widget.handle_blur()
			focused_widget = null	
		pass
		
	func focus(id: String):	
		if current.has(id):
			if focused_widget != null:
				focused_widget.handle_blur()
				
			focused_widget = widgets[id]
			focused_widget.handle_focus()
		else:
			dev.logr("HUDStateManager", "failed to focus widget '%s' - widget not presemt in the current state" % id)
	
	func blur():
		unset_focus()
	
	func get_widget(id: String):
		if widgets.has(id):
			return widgets[id]
		else:
			return null
			
	func get_widget_with_path(path: Array[String]):
		var result: GameWidget = get_widget(path.pop_front())
		
		while result != null and path.size() > 0:
			result = result.state.get_widget(path.pop_front())
			
		dev.logd("HUDManager", "found % by query: %s" % [result, ",".join(path)])
		return result
	
				
	func get_focus_tree()->Array[String]:
		var path: Array[String]
		var _state: HUDStateManager = self
		var _widget: GameWidget = widget
		
		while _state.focused_widget != null:
			
			_widget = _state.focused_widget
			if _widget != null:
				_state = _widget.state
				path.push_back(_widget.id)
				
			
			
		#print(path)
		return path

	func compute_widget_path()->Array[String]:
		var path: Array[String]
		var _widget = widget
		while _widget != null:
			path.push_front(_widget.id)
			_widget = _widget.parent_state.widget
		return path

	
var state: HUDStateManager = HUDStateManager.new()
var cancel_action_locked: bool = false

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
	if app.is_menu_input_mode() and state.focused_widget != null:
		if Input.is_action_just_pressed("ui_left"):
			state.focused_widget.navigate(Vector2.LEFT)
		if Input.is_action_just_pressed("ui_right"):
			state.focused_widget.navigate(Vector2.RIGHT)
		if Input.is_action_just_pressed("ui_up"):
			state.focused_widget.navigate(Vector2.UP)
		if Input.is_action_just_pressed("ui_down"):
			state.focused_widget.navigate(Vector2.DOWN)		
		if Input.is_action_just_pressed("ui_accept"):
			state.focused_widget.accept()
		if Input.is_action_just_pressed("ui_cancel"):
			state.focused_widget.cancel()
		
	cancel_action_locked = state.focused_widget != null		
	
	dev.print_screen("hud-manager-state", "Current root HUD state: [%s]" % "; ".join(state.current))
	dev.print_screen("hud-manager-focused", "Root HUD widget in focus: [%s]" % ", ".join(state.get_focus_tree()))
	
func _get_focused_widget_path()-> String:
	var result: String = ""
	var focused_widget = state.focused_widget
	
	while focused_widget != null:
		result = focused_widget.id  +  "/" + result
		focused_widget = focused_widget.state.focused_widget
		
	return result
	
func focus(widget: GameWidget):
	dev.logd("HUDManager", "prepare to focus widget '%s'" % widget.id)
	var widget_path = widget.state.compute_widget_path()
	dev.logd("HUDManager", "focusing widget '%s', widget path - [%s]" % [widget.id, ", ".join(widget_path)])
	
	var _id = widget_path.pop_front()
	var _state: HUDStateManager = state
	
	while _id != null:
		_state.focus(_id)
		if _state.widgets.has(_id):
			_state = _state.widgets[_id].state
			_id = widget_path.pop_front()
		else:
			_id = null
			dev.logd("HUDManager", "failed to focus [%s] - some widgets not exist (yet?)" % [widget_path])
			

func blur():
	state.blur()
