extends Control

class_name GameMenuItemController

@export_subgroup("Referencies")
@export var label_element: Label
@export var value_element: Label

@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree

var is_selected: bool = false
var menu_controller: GameMenuGenerator 
var descriptor: GameMenuItemDescriptor

@export var toggle_value: bool = false
@export var select_value: String = ""
@export var range_value: float = 0

var controller: GameMenuGenerator

func _ready():
	animation_tree.active = true
	#animation_player.play("Selected")
	pass
	
func initialize(_menu_controller: GameMenuGenerator, _descriptor: GameMenuItemDescriptor, alt_label: String = ""):
	menu_controller = _menu_controller
	descriptor = _descriptor
	is_selected = false
	
	var label_text: String = descriptor.label
	
	if label_text == "" and alt_label != "":
		label_text = alt_label
		
	_init_value()	
	_update_value()
		
	label_element.text = label_text
	pass


func _process(delta):
	#animation_player.play("Selected")
	pass
	#print(animation_tree)
	
	animation_tree["parameters/conditions/normal"] = not is_selected
	animation_tree["parameters/conditions/selected"] = is_selected

func next_value():
	match descriptor.type:
		GameMenuItemDescriptor.EGameMenuItemType.TOGGLE:
			toggle_value = !toggle_value
		GameMenuItemDescriptor.EGameMenuItemType.SELECT:
			var selected_index = descriptor.select_options.find(select_value)
			selected_index = clamp(selected_index + 1, 0, descriptor.select_options.size() - 1)
			select_value = descriptor.select_options[selected_index]
		GameMenuItemDescriptor.EGameMenuItemType.RANGE:
			range_value = clampf(
				range_value + ((descriptor.range_max - descriptor.range_min) / descriptor.range_steps), 
				descriptor.range_min, 
				descriptor.range_max
			)
		
	descriptor.on_select.emit(self)
	controller.submit(self)
	_update_value()
	pass
	
func prev_value():
	match descriptor.type:
		GameMenuItemDescriptor.EGameMenuItemType.TOGGLE:
			toggle_value = !toggle_value
		GameMenuItemDescriptor.EGameMenuItemType.SELECT:
			var selected_index = descriptor.select_options.find(select_value)
			selected_index = clamp(selected_index - 1, 0, descriptor.select_options.size() - 1)
			select_value = descriptor.select_options[selected_index]
		GameMenuItemDescriptor.EGameMenuItemType.RANGE:
			range_value = clampf(
				range_value - ((descriptor.range_max - descriptor.range_min) / descriptor.range_steps), 
				descriptor.range_min, 
				descriptor.range_max
			)
	descriptor.on_select.emit(self)
	controller.submit(self)
	_update_value()
	pass

func _init_value():
	match descriptor.type:
		GameMenuItemDescriptor.EGameMenuItemType.TOGGLE:
			toggle_value = descriptor.toggle_initial
		GameMenuItemDescriptor.EGameMenuItemType.SELECT:
			select_value = descriptor.select_initial
		GameMenuItemDescriptor.EGameMenuItemType.RANGE:
			range_value = descriptor.range_initial
		
		
func _update_value():
	match descriptor.type:
		GameMenuItemDescriptor.EGameMenuItemType.TOGGLE:
			_update_toggle_value()
		GameMenuItemDescriptor.EGameMenuItemType.SELECT:
			_update_select_value()
		GameMenuItemDescriptor.EGameMenuItemType.RANGE:
			_update_range_value()
		_:
			_update_noop_value()

func _update_toggle_value():
	value_element.text = "Yes" if toggle_value else "No"
	
func _update_select_value():
	value_element.text = "< " + select_value + " >" 

func _update_range_value():
	value_element.text = "%.0f/%s" % [range_value, descriptor.range_max]
	
func _update_noop_value():
	value_element.text = ""
