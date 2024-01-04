extends GameWidget

class_name GameMenuGenerator

enum EMenuLayoutType {
	Vertical,
	Horizontal,
	Grid
}

@export var menu: GameMenuItemDescriptor
@export var target_container: Control
@export var item_template: PackedScene
@export var breadcrumbs_label: Label

var _current_page: GameMenuItemDescriptor
var _items: Array[GameMenuItemController]
var selected_index: int = 0
var allow_input: bool = true
var current_path: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if menu != null and target_container != null and item_template != null:
		initialize()
	
	pass # Replace with function body.

func initialize():
	_open_directory(menu)
	pass
	
func accept():
	_handle_accept()
	pass
	
func cancel():
	if _current_page.get_parent() is GameMenuItemDescriptor:
		_up()
	else:
		super.cancel()
	pass
	
func display():
	super.display()
	
func conceal():
	super.conceal()
	
func navigate(direction: Vector2):
	if direction == Vector2.UP:
		selected_index = selected_index - 1 if selected_index > 0 else _current_page.get_child_count() - 1
	if direction == Vector2.DOWN:
		selected_index = selected_index + 1 if selected_index < _current_page.get_child_count() - 1 else 0
	if direction == Vector2.LEFT:
		_items[selected_index].prev_value()
	if direction == Vector2.RIGHT:
		_items[selected_index].next_value()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for index in _items.size():
		_items[index].is_selected = selected_index == index


func _build_page():
	dev.logd("GameMenuGenerator", "building menu page...")
	
	for index in _current_page.get_child_count():
		if index >= _items.size():
			var new_item: GameMenuItemController = item_template.instantiate()
			new_item.duplicate()
			new_item.controller = self
			target_container.add_child(new_item)
			_items.append(new_item)
			pass
			
		var item: GameMenuItemController = _items[index]
		var item_descriptor: GameMenuItemDescriptor = _current_page.get_child(index)
		
		item.initialize(self, item_descriptor, item_descriptor.name)
	pass
	
	for index in _items.size():
		_items[index].visible = index < _current_page.get_child_count() 
		
	if _items.size() > 0:
		_items[0].is_selected = true

func _open_directory(dir: GameMenuItemDescriptor, open_up: bool = false):
	dev.logd("GameMenuGenerator", "opening as directory: %s" % dir)
	
	if open_up:
		current_path.pop_back()
	else:
		current_path.push_back(dir.id)
	
	_current_page = dir
	selected_index = 0
	
	_update_breadcrumbs()	
	_build_page()

func _up():
	if _current_page.get_parent() is GameMenuItemDescriptor:
		_open_directory(_current_page.get_parent(), true)
		
func _update_breadcrumbs():
	if breadcrumbs_label != null:
		breadcrumbs_label.text = " / ".join(current_path)

func _handle_accept():
	var item_descriptor: GameMenuItemDescriptor = _current_page.get_child(selected_index)
	
	dev.logd("GameMenuGenerator", "accepting on item %s (page - %s)" % [selected_index, _current_page])
	print(item_descriptor.get_child_count())
	
	if item_descriptor.get_child_count() > 0:
		_open_directory(item_descriptor)
	else:
		_items[selected_index].next_value()

func submit(item: GameMenuItemController):
	dev.logd("GameMenuGenerator", "item submit %s" % item)
	
	
