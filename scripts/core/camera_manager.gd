extends Node

class_name CameraManager

const SNAP_DISTANCE: float = 0.05
const INITIAL_CAMERA_SPAWN_POSITION: Vector3 = Vector3(0, 256, 0)
const INITIAL_CAMERA_FOV: float = 30
const LERP_SYNC_ALPHA: float = 0.05

var camera: Camera3D
var target_camera: Camera3D 

enum ETargetSyncType {
	None,
	Immediate,
	Lerp,
	Move,
	LookAt
}

enum ETargetSyncMode {
	None,
	Approach,
	Follow,
}


# false if camera only flies to the target one, true if it is already "snapped"
var mode: ETargetSyncMode = ETargetSyncMode.Approach
var follow_type: ETargetSyncType = ETargetSyncType.Immediate
var approach_type: ETargetSyncType = ETargetSyncType.Immediate
var fov_sync_type: ETargetSyncType = ETargetSyncType.Lerp

# seconds
var move_time: float = 0.5
var fov_time: float = 1

var _move_speed: float = 1
var _fov_speed: float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	dev.logd("CameraManager", "inited")
	_create_main_camera()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	if camera == null:
		_create_main_camera()
		
	dev.print_screen("camera_mode", "camera mode: %s" % mode)
	if target_camera == null and players.current != null:
		if players.current.get_camera() is Camera3D:
			set_camera(players.current.get_camera())
	
	if target_camera != null:
		var distance: float = target_camera.global_position.distance_to(camera.global_position)
		
		if mode == ETargetSyncMode.Approach and distance < SNAP_DISTANCE:
			mode = ETargetSyncMode.Follow
			
		var sync_type: ETargetSyncType =  ETargetSyncType.None
			
		match mode:
			ETargetSyncMode.Approach:
				sync_type = approach_type
				pass
			ETargetSyncMode.Follow:
				sync_type = follow_type
				pass
		
		match sync_type:
			ETargetSyncType.Immediate:
				camera.global_position = target_camera.global_position
				camera.global_rotation = target_camera.global_rotation
				pass
			ETargetSyncType.Lerp:	
				camera.global_position = camera.global_position.lerp(target_camera.global_position, LERP_SYNC_ALPHA)
				camera.global_transform.basis = tools.lerp_transform_rotation(camera.global_transform, target_camera.global_transform, LERP_SYNC_ALPHA)
				#camera.global_rotation = camera.global_rotation.lerp(target_camera.global_rotation, 0.1)
			
			ETargetSyncType.Move:	
				camera.global_position = camera.global_position.move_toward(target_camera.global_position, _move_speed * delta)
				camera.global_rotation = camera.global_rotation.move_toward(target_camera.global_rotation, _move_speed * delta)
				
		# fov
		match fov_sync_type:
			ETargetSyncType.Immediate:
				camera.fov = target_camera.fov
			ETargetSyncType.Lerp:
				camera.fov = lerpf(camera.fov, target_camera.fov, 0.1)
			ETargetSyncType.Move:
				camera.fov = move_toward(camera.fov,  target_camera.fov, _fov_speed * delta)


func set_camera(_target_camera: Camera3D, _approach_type: ETargetSyncType = ETargetSyncType.Move):
	dev.logd("CameraManager", "setting target camera to %s" % _target_camera.name)
	var distance: float =  camera.global_position.distance_to(_target_camera.global_position)
	
	camera.cull_mask = _target_camera.cull_mask
	approach_type = _approach_type
	_move_speed = distance / move_time
	_fov_speed = abs(_target_camera.fov - camera.fov) / fov_time
	mode = ETargetSyncMode.Approach	
	target_camera = _target_camera
	

func _create_main_camera():
	dev.logd("CameraManager", "creating main camera...")
	camera = Camera3D.new()
	camera.fov = INITIAL_CAMERA_FOV
	camera.global_position = INITIAL_CAMERA_SPAWN_POSITION
	camera.rotate_x(deg_to_rad(-90))
	
	var audio_listener: AudioListener3D = AudioListener3D.new()
	camera.add_child(audio_listener)
	
	tools.get_scene().add_child(camera)
	camera.current = true
