extends Resource

class_name RGameMenu

enum RGameMenuItemType {
	MENU,
	LABEL,
	BUTTON,
	TOGGLE,
	SELECT,
	RANGE,
	SEPARATOR,
}

@export var label: String = "Enter Name"
@export var type: RGameMenuItemType = RGameMenuItemType.MENU

@export_subgroup("Menu")
@export var content: Array[RGameMenu]

@export_subgroup("Toggle")
@export var toggle_initial: bool

@export_subgroup("Select")
@export var select_initial: String
@export var select_options: Array[String]

@export_subgroup("Range")
@export var range_initial: float = 50
@export var range_min: float = 0
@export var range_max: float = 100



	
