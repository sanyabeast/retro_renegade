extends Node
class_name AppManager

enum EInputMode {
	Character,
	CharacterAndMenu,
	Menu,
	MenuAndPointer
}

var config: RGameConfig = load("res://resources/config.tres")
var tasks: tools.TaskPlanner = tools.TaskPlanner.new()
var input_mode: EInputMode = EInputMode.CharacterAndMenu
var in_game_input_mode: EInputMode = EInputMode.CharacterAndMenu
var pause_menu_input_mode: EInputMode = EInputMode.Menu
var focused: bool = false


func _ready():
	dev.logd("AppManager", "loaded config %s" % config.resource_name)
	dev.print_screen("app-tasks-size", "App tasks list size: %s" % tasks.list.size())
	dev.print_screen("app-tasks-sch-size", "App tasks schedule size: %s" % tasks.schedule_list.keys().size())
	
	world.connect("on_before_travel", _handle_travel)

func is_character_input_mode():
	return input_mode == EInputMode.Character or input_mode == EInputMode.CharacterAndMenu

func is_menu_input_mode():
	return input_mode == EInputMode.Menu or input_mode == EInputMode.MenuAndPointer or input_mode == EInputMode.CharacterAndMenu	

func _physics_process(delta):
	tasks.update()

func _process(delta):
	_update_mouse_mode()
	
	if game.paused:
		input_mode = pause_menu_input_mode
	else:
		input_mode = in_game_input_mode
	

func release_pointer(blur: bool = false):
	if blur:
		focused = false
		
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func capture_pointer():
	NOTIFICATION_WM_WINDOW_FOCUS_IN
	if focused and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _update_mouse_mode():
	
	match input_mode:
		EInputMode.MenuAndPointer:
			release_pointer()
		_:
			capture_pointer()
	

func elease_pointer():
	pass

func _input(event):	
		if event is InputEventMouseButton:
			focused = true

func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focused = false
			release_pointer()
			pass
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			focused = true
			pass
		NOTIFICATION_APPLICATION_PAUSED:
			dev.logd("AppManager", "application paused")
		NOTIFICATION_APPLICATION_RESUMED:
			dev.logd("AppManager", "application resume")
func _handle_travel(scene_path: String):
	hud.reset()
