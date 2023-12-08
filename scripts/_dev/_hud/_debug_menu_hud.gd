extends Control

var menu_items = []
var current_selection = 0

var actions = [
	{"name": "respawn player", "function": self.respawn_player},
	{"name": "reload current_scene", "function": self.reload_current_scene},
	# Add more actions here
]

# Example action functionsx
func respawn_player():
	players.respawn_player()
	hide()
	pass

func reload_current_scene():
	tools.reload_scene()
	pass

func _ready():
	var menu_container = $MenuContainer # Update with your VBoxContainer's name
	for action in actions:
		var label = Label.new()
		label.text = action.name
		menu_container.add_child(label) # Add labels to the VBoxContainer
		menu_items.append(label)
	
	select_item(0)
	hide()

func _input(event):
	if event.is_action_pressed("debug_menu"):
		if is_visible():
			#game.resume()
			hide()
		else:
			#game.pause()
			show()
			select_item(0)
	
	if is_visible():
		if event.is_action_pressed("ui_down"):
			select_item((current_selection + 1) % menu_items.size())
		elif event.is_action_pressed("ui_up"):
			select_item((current_selection - 1 + menu_items.size()) % menu_items.size())
		elif event.is_action_pressed("ui_accept"):
			execute_action(current_selection)

func select_item(index):
	var label: Label = menu_items[current_selection]
	menu_items[current_selection].add_theme_color_override("font_color", Color(1, 1, 1))
	current_selection = index
	menu_items[current_selection].add_theme_color_override("font_color", Color(1, 0, 0))

func execute_action(index):
	if index >= 0 and index < actions.size():
		actions[index].function.call()
