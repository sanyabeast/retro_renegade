extends GameWidget

var menu_items = []
var current_selection = 0

var dev_scenes = [
	"res://scenes/levels/_practice_range.tscn",
	"res://scenes/levels/_practice_range_b.tscn",
	"res://scenes/levels/_solarpunk_village.tscn"
]

var actions = [
	{"name": "respawn player", "function": self.respawn_player},
	{"name": "respawn player (random place)", "function": self.respawn_player_random},
	{"name": "reload current_scene", "function": self.reload_current_scene},
	{"name": "load random scene", "function": self.load_random_scene},
	{"name": "remove some rigidbodies", "function": self.remove_some_rb},
	{"name": "next player camera", "function": self.next_player_camera},
	{"name": "force everybody is npc", "function": self.force_npc},
	{"name": "possess random character", "function": self.posses_random_character}
	# Add more actions here
]

# Example action functionsx
func respawn_player():
	players.respawn_player()
	hide()
	pass
	
func respawn_player_random():
	players.respawn_player(world.get_random_reachable_point())
	pass
	
func force_npc():
	npcs.force_everybody_npc = not npcs.force_everybody_npc
	pass

func reload_current_scene():
	tools.reload_scene()
	pass

func posses_random_character():
	players.set_player(tools.get_random_element_from_array(world.characters))
	
func remove_some_rb():
	if world.rigid_bodies.size() > 0:
		#world.rigid_bodies.remove_at(randi() % world.rigid_bodies.size())	
		
		world.rigid_bodies[randi() % world.rigid_bodies.size()].queue_free()
	
func next_player_camera():
	if players.current != null:
		players.current.next_camera_mode()	
	
func load_random_scene():
	tools.load_scene(tools.get_random_element_from_array(dev_scenes))
	pass	

func _ready():
	super._ready()
	var menu_container = $MenuContainer # Update with your VBoxContainer's name
	for action in actions:
		var label = Label.new()
		label.text = action.name
		menu_container.add_child(label) # Add labels to the VBoxContainer
		menu_items.append(label)
	
	select_item(0)

func _input(event):
	pass

func navigate(direction: Vector2):
	if direction == Vector2.UP:
		select_item((current_selection - 1 + menu_items.size()) % menu_items.size())
	elif direction == Vector2.DOWN:
		select_item((current_selection + 1) % menu_items.size())
	pass

func accept():
	execute_action(current_selection)

func select_item(index):
	var label: Label = menu_items[current_selection]
	menu_items[current_selection].add_theme_color_override("font_color", Color(1, 1, 1))
	current_selection = index
	menu_items[current_selection].add_theme_color_override("font_color", Color(1, 0, 0))

func execute_action(index):
	if index >= 0 and index < actions.size():
		actions[index].function.call()
