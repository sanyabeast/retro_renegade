extends Node

class_name GameMenuItemDescriptor

enum EGameMenuItemType {
	BUTTON,
	TOGGLE,
	SELECT,
	RANGE,
	SEPARATOR,
}

@export var label: String = ""
@export var type: EGameMenuItemType = EGameMenuItemType.BUTTON

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

signal on_select(item: GameMenuItemController)
