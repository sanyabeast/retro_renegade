extends Control

class_name GameMenuGenerator

enum EMenuLayoutType {
	Vertical,
	Horizontal,
	Grid
}

@export var menu: GameMenuItemDescriptor
@export var target_container: Control
@export var item_template: PackedScene
@export var anim_player: AnimationPlayer

var _current_page: GameMenuItemDescriptor
var _items: Array[GameMenuItemController]
var _selected_item_index: int = 0
var _current_page_items_count: int = 0
var allow_input: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if menu != null and target_container != null and item_template != null:
		initialize()
	
	pass # Replace with function body.

func initialize():
	_open_directory(menu)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if allow_input:
		if Input.is_action_just_pressed("ui_up"):
			_items[_selected_item_index].is_selected = false
			_selected_item_index = _selected_item_index - 1 if _selected_item_index > 0 else _current_page_items_count - 1
			_items[_selected_item_index].is_selected = true
			
		if Input.is_action_just_pressed("ui_down"):
			_items[_selected_item_index].is_selected = false
			_selected_item_index = _selected_item_index + 1 if _selected_item_index < _current_page_items_count - 1 else 0
			_items[_selected_item_index].is_selected = true
			
		if Input.is_action_just_pressed("ui_accept"):
			_handle_accept()
			
		if Input.is_action_just_pressed("ui_cancel"):
			_up()	
			
		if Input.is_action_just_pressed("ui_left"):
			_items[_selected_item_index].prev_value()
			
		if Input.is_action_just_pressed("ui_right"):
			_items[_selected_item_index].next_value()

func _start_build_page():
	#_build_page()
	if anim_player == null:
		_build_page()
	else:
		anim_player.play("OpenDirectory")

func _build_page():
	dev.logd("GameMenuGenerator", "building menu page...")
	_current_page_items_count = _current_page.get_child_count()
	
	for index in _current_page_items_count:
		if index >= _items.size():
			var new_item: GameMenuItemController = item_template.instantiate()
			new_item.duplicate()
			target_container.add_child(new_item)
			_items.append(new_item)
			pass
			
		var item: GameMenuItemController = _items[index]
		var item_descriptor: GameMenuItemDescriptor = _current_page.get_child(index)
		
		item.initialize(self, item_descriptor, _current_page.get_child(index).name)
	pass
	
	for index in _items.size():
		_items[index].visible = index < _current_page_items_count 
		
	if _items.size() > 0:
		_items[0].is_selected = true

func _open_directory(dir: GameMenuItemDescriptor):
	_current_page = dir
	_start_build_page()

func _up():
	if _current_page.get_parent() is GameMenuItemDescriptor:
		_open_directory(_current_page.get_parent())

func _handle_accept():
	if _current_page.get_child(_selected_item_index) and _current_page.get_child(_selected_item_index).get_child_count() > 0:
			_open_directory(_current_page.get_child(_selected_item_index))
	else:
		_items[_selected_item_index].next_value()
