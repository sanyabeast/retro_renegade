extends Node

class_name ActionsManager

enum EActionType {
	CUSTOM,
	SCENE_LOAD,
	SCENE_RELOAD,
	SCENE_SPAWN,
	OBJECT_MOVE,
	OBJECT_DESTROY,
	RIGIDBODY_SET_VELOCITY,
	GAME_PAUSE,
	GAME_RESUME,
	GAME_SAVE,
	GAME_LOAD,
	GAME_TOGGLE_PAUSE,
	GAME_SET_SPEED,
	APP_QUIT,
	APP_RESTART,
	APP_SETTINGS_SET_SOUND_MASTER_VOLUME,
	APP_SETTINGS_SET_GRAPHICS_FSR_PRESET,
	APP_SETTINGS_SET_GRAPHICS_FSR_ENABLED,
	APP_SETTINGS_SET_GRAPHICS_FSR_QUALITY,
	APP_SETTINGS_SET_GRAPHICS_SSAO_ENABLED,
	APP_SETTINGS_SET_GRAPHICS_SSGI_ENABLED,
	APP_SETTINGS_SET_INPUT_MOUSE_MASTER_SENSITIVITY,
	WORLD_SET_DAYTIME,
	WORLD_SET_DAYTIME_SPEED
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func perform(action: EActionType, custom_type: String, payload: Dictionary):
	match action:
		EActionType.CUSTOM:
			perform_custom_action(custom_type, payload)
			pass

func perform_custom_action(custom_type: String, payload: Dictionary):
	match custom_type:
		"test":
			dev.logd("ActionsManager", "test action done")
