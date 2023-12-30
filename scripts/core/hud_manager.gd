extends Node

class_name HUDManager

class HUDStateManager:
	var widgets: Dictionary = {}
	var focused_widget: GameWidget
	var current: Array[String] = []
	var history: Array[Array]
	
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
		
	func _find_next_focused_item():
		for item in current:
			if widgets[item].interactive:
				focused_widget = widgets[item]
				break
	func exists(id: String):
		return widgets.has(id)
	func is_present(id: String):
		return current.has(id)
	func show(id: String):
		if widgets.has(id):
			widgets[id].show()
			dev.logd("HUDStateManager", "showing '%s'" % id)
			if widgets[id].interactive:
				focused_widget = widgets[id]
		else:
			dev.logd("HUDStateManager", "Failed to SHOW '%s' - widget does not linked" % id)
			
	func hide(id: String):
		if widgets.has(id):
			widgets[id].hide()
			dev.logd("HUDStateManager", "hiding '%s'" % id)
			
			if focused_widget == widgets[id]:
				_find_next_focused_item()
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
		focused_widget = null	
		pass
	
var state: HUDStateManager = HUDStateManager.new()

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
		var nav_direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
		state.focused_widget.navigate(nav_direction)
		
		if Input.is_action_just_pressed("ui_accept"):
			state.focused_widget.accept()
			
		if Input.is_action_just_pressed("ui_cancel"):
			state.focused_widget.cancel()
