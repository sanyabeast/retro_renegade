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
var _selected_item_index: int = 0
var _current_page_items_count: int = 0
var allow_input: bool = true
var _current_menu_handler: GameMenuHandler
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
		_selected_item_index = _selected_item_index - 1 if _selected_item_index > 0 else _current_page_items_count - 1
	if direction == Vector2.DOWN:
		_selected_item_index = _selected_item_index + 1 if _selected_item_index < _current_page_items_count - 1 else 0
	if direction == Vector2.LEFT:
		_items[_selected_item_index].prev_value()
	if direction == Vector2.RIGHT:
		_items[_selected_item_index].next_value()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for index in _items.size():
		_items[index].is_selected = _selected_item_index == index


func _build_page():
	dev.logd("GameMenuGenerator", "building menu page...")
	
	
	for index in _current_page_items_count:
		if index >= _items.size():
			var new_item: GameMenuItemController = item_template.instantiate()
			new_item.duplicate()
			new_item.controller = self
			target_container.add_child(new_item)
			_items.append(new_item)
			pass
			
		var item: GameMenuItemController = _items[index]
		var item_descriptor: GameMenuItemDescriptor = _get_page_item_descriptor(_current_page, index)
		
		item.initialize(self, item_descriptor, item_descriptor.name)
	pass
	
	for index in _items.size():
		_items[index].visible = index < _current_page_items_count 
		
	if _items.size() > 0:
		_items[0].is_selected = true

func _get_page_items_count(page: GameMenuItemDescriptor)->int:
	var count = 0
	for index in page.get_child_count():
		if page.get_child(index) is GameMenuItemDescriptor:
			count += 1
	return count

func _get_page_handler(page: GameMenuItemDescriptor)-> GameMenuHandler:
	var result: GameMenuHandler = _current_menu_handler
	for index in page.get_child_count():
		if page.get_child(index) is GameMenuHandler:
			result = page.get_child(index)
			break
	return result

func _get_page_item_descriptor(page: GameMenuItemDescriptor, index: int)-> GameMenuItemDescriptor:
	var count = 0
	for i in page.get_child_count():
		if page.get_child(i) is GameMenuItemDescriptor:
			if count == index:
				return page.get_child(i)
				
			count += 1
	return null

func _open_directory(dir: GameMenuItemDescriptor, open_up: bool = false):
	dev.logd("GameMenuGenerator", "opening as directory: %s" % dir)
	_current_page = dir
	_current_menu_handler = _get_page_handler(_current_page)
	_current_page_items_count = _get_page_items_count(_current_page)
	_selected_item_index = 0
	
	if open_up:
		current_path.pop_back()
	else:
		current_path.push_back(dir.id)
		
	_update_breadcrumbs()	
	_build_page()

func _up():
	if _current_page.get_parent() is GameMenuItemDescriptor:
		_open_directory(_current_page.get_parent(), true)
		

func _update_breadcrumbs():
	if breadcrumbs_label != null:
		breadcrumbs_label.text = " / ".join(current_path)

func _handle_accept():
	var item_descriptor: GameMenuItemDescriptor = _get_page_item_descriptor(_current_page, _selected_item_index)
	
	dev.logd("GameMenuGenerator", "accepting on item %s (page - %s)" % [_selected_item_index, _current_page])
	print(_get_page_items_count(item_descriptor))
	
	if _get_page_items_count(item_descriptor) > 0:
			_open_directory(item_descriptor)
	else:
		_items[_selected_item_index].next_value()

func submit(item: GameMenuItemController):
	if _current_menu_handler != null:
		var total_path = current_path.duplicate()
		total_path.push_back(item.descriptor.id)
		_current_menu_handler.submit(total_path, item)
	else:
		dev.logr("GameMenuGenerator", "failed to submit menu item: controller at %s is NULL" % _current_page)
	
	
