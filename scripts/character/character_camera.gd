extends Node3D

class_name GameCharacterCameraRig

enum EGameCharacterCameraMode {
	FirstPerson,
	ThirdPerson
}


@export_subgroup("First Person Camera")
@export var camera_1p: Camera3D
@export var camera_1p_rig: Node3D
@export var camera_1p_attitude_min: float = -75
@export var camera_1p_attitude_max: float = 75
@export var camera_1p_sensitivity: float = 1

@export_subgroup("Third Person Camera")
@export var camera_3p: Camera3D
@export var camera_3p_rig: Node3D
@export var camera_3p_attitude_min: float = -75
@export var camera_3p_attitude_max: float = 0
@export var camera_3p_sensitivity: float = 1

@export var camera_mode: EGameCharacterCameraMode = EGameCharacterCameraMode.FirstPerson

@export var body_controller: GameCharacterBody

var character: GameCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if body_controller != null and body_controller.head_pin_point != null:
		global_position = body_controller.head_pin_point.global_position
	
func set_camera_mode(new_mode: EGameCharacterCameraMode):
	camera_mode = new_mode
	camera_manager.set_camera(get_camera(), CameraManager.ETargetSyncType.Move)
	
func next_camera_mode():
	camera_mode = (camera_mode + 1) % EGameCharacterCameraMode.size()
	camera_manager.set_camera(get_camera(), CameraManager.ETargetSyncType.Move)

func get_camera() -> Camera3D:
	match camera_mode:
		EGameCharacterCameraMode.FirstPerson:
			return camera_1p
		EGameCharacterCameraMode.ThirdPerson:
			return camera_3p
	return camera_1p

func process_camera_input(event):
	# 1P CAMERA
	match camera_mode:
		EGameCharacterCameraMode.FirstPerson:
			camera_1p_rig.rotate_x(deg_to_rad(event.relative.y * app.config.first_person_camera_sensitivity * camera_1p_sensitivity * -1))
			camera_1p_rig.rotation_degrees.x = clamp(camera_1p_rig.rotation_degrees.x, camera_1p_attitude_min, camera_1p_attitude_max)
			pass
		EGameCharacterCameraMode.ThirdPerson:
			# 3P CAMERA
			camera_3p_rig.rotate_x(deg_to_rad(event.relative.y * app.config.third_person_camera_sensitivity * camera_3p_sensitivity * -1))
			camera_3p_rig.rotation_degrees.x = clamp(camera_3p_rig.rotation_degrees.x, camera_3p_attitude_min, camera_3p_attitude_max)
			pass
	#  PLAYER
	if character != null:
		character.rotate_y(deg_to_rad(event.relative.x * app.config.first_person_camera_sensitivity * -1))
		
