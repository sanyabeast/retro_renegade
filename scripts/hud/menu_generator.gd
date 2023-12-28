extends Control

class_name GameMenuGenerator

@export var menu: RGameMenu
@export var kit: RGameMenuKit

# Called when the node enters the scene tree for the first time.
func _ready():
	if menu != null and kit != null:
		initialize(menu, kit)
	
	pass # Replace with function body.

func initialize(menu: RGameMenu, kit: RGameMenuKit):
	_generate_menu(menu, kit, self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _generate_menu(menu: RGameMenu, kit: RGameMenuKit, parent: Control):
	var menu_item = _create_menu_item(menu, kit)
	_setup_menu_item(menu_item, menu, kit)
	
	if parent != null:
		parent.add_child(menu_item)
		
	return menu_item
	
			
func _create_menu_item(menu: RGameMenu, kit: RGameMenuKit):
	var type: RGameMenu.RGameMenuItemType = menu.type
	dev.logd("GameMenuGenerator", "creating item of type %s" % type)
	
	match type:
		RGameMenu.RGameMenuItemType.MENU:
			return VBoxContainer.new()
		RGameMenu.RGameMenuItemType.LABEL:
			return Label.new()

func _setup_menu_item(menu_item: Control, menu: RGameMenu, kit: RGameMenuKit):
	var type: RGameMenu.RGameMenuItemType = menu.type
	
	match type:
		RGameMenu.RGameMenuItemType.MENU:
			for item in menu.content:
				_generate_menu(item, kit, menu_item)
				
		RGameMenu.RGameMenuItemType.LABEL:
			menu_item.text = menu.label
