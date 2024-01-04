extends Node

class_name GameMenuItemDescriptor

enum EGameMenuItemType {
	BUTTON,
	TOGGLE,
	SELECT,
	RANGE,
	SEPARATOR,
}

@export var id: String = ""
@export var label: String = ""
@export var type: EGameMenuItemType = EGameMenuItemType.BUTTON

@export_category("Values")
@export_subgroup("Toggle")
@export var toggle_initial: bool

@export_subgroup("Select")
@export var select_initial: String
@export var select_options: Array[String]

@export_subgroup("Range")
@export var range_initial: float = 50
@export var range_steps: float = 10
@export var range_min: float = 0
@export var range_max: float = 100

@export_subgroup("Data")
@export var data: Dictionary = {}

@export_subgroup("Actions")
@export var actions: Array[RAction]


signal on_select(item: GameMenuItemController)

func _init():
	#assert(id != "", "GameMenuItemDescriptor: ID must be not empty string %s" % self)
	print(self)

func _to_string():
	return "GameMenuItemDescriptor(id=%s, name=%s, label=%s, instance_id=%s, data=%s)" % [id, name, label, get_instance_id(), data]
