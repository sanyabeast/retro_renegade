extends Node3D


class_name GameCharacterBodyIKController

@export_subgroup("IK Systems")
@export var head_ik: SkeletonIK3D
@export var body_ik: SkeletonIK3D
@export var hand_l_ik: SkeletonIK3D
@export var hand_r_ik: SkeletonIK3D
@export var foot_l_ik: SkeletonIK3D
@export var foot_r_ik: SkeletonIK3D

@export_subgroup("IK Targets")
@export var head_target: Node3D
@export var body_target: Node3D
@export var hand_l_target: Node3D
@export var hand_r_target: Node3D
@export var foot_l_target: Node3D
@export var foot_r_target: Node3D

@export_subgroup("Foot IK")
@export var foot_ik_enabled: bool = true
@export var foot_ik_interpolation_max: float = 0.75
@export var foot_ik_interpolation_transition_speed: float = 4

@export var foot_l_ray: RayCast3D
@export var foot_l_bone_name: String = 'mixamorig_LeftFoot'
@export var foot_l_bone_tracker: BoneAttachment3D

@export var foot_r_ray: RayCast3D
@export var foot_r_bone_name: String = 'mixamorig_RightFoot'
@export var foot_r_bone_tracker: BoneAttachment3D

@export_subgroup("Hands IK")
@export var hands_ik_enabled: bool = true
@export var hands_ik_interpolation_max: float = 0.75
@export var hands_ik_interpolation_transition_speed: float = 4

@export_subgroup("Body IK")
@export var body_ik_enabled: bool = true
@export var body_ik_interpolation_max: float = 0.75
@export var body_ik_interpolation_transition_speed: float = 4

@export var body_target_interpolation: float = 0.75
@export var body_target_rotation_y: float = 0
@export var body_target_rotation_x: float = 0
@export var body_target_rotation_z: float = 0

@export_subgroup("Referencies")
## Automatically assigned by GameCharacterBodyController
@export var skeleton: Skeleton3D
## Automatically assigned by GameCharacterBodyController
@export var character: GameCharacter

var _hand_l_ik_target_interpolation: float = 0.5
var _hand_r_ik_target_interpolation: float = 0.5

var _foot_ik_target_interpolation: float = 0.5
var _foot_r_target_offset: float = 0
var _foot_l_target_offset: float = 0

var _inited: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize()	
	pass # Replace with function body.

func initialize():
	if not _inited and skeleton != null and character != null:
		_inited = true
		_setup_tree(self)
		_setup_tree(skeleton)
		
		# FOOT IK SETTING UP
		_foot_l_target_offset = 0
		_foot_r_target_offset = 0
		
		if foot_l_ik != null and foot_r_ik != null:
			foot_l_ray.add_exception(character)
			foot_r_ray.add_exception(character)
			
			if foot_ik_enabled:
				foot_l_ik.start()
				foot_r_ik.start()
		
		# HANDS_ID
		if hand_l_ik != null and hand_r_ik != null:
			if hands_ik_enabled:
				hand_l_ik.start()
				hand_r_ik.start()
				
				
		if body_ik_enabled:
			if body_ik != null and body_target != null:
				body_target.rotation_degrees.x = body_target_rotation_x
				body_target.rotation_degrees.y = body_target_rotation_y
				body_target.rotation_degrees.z = body_target_rotation_z
				
				body_ik.start()
				dev.logd("GameCharacterBodyIKController", "body ik started")
			else:
				assert(body_ik != null, "GameCharacterBodyIKController: Body IK: body_ik must be set up to function")
				assert(body_target != null, "GameCharacterBodyIKController: Body IK: body_target must be set up to function")
		
	
	pass
	
func _setup_tree(node):
	if node is Node3D and not node is SkeletonIK3D:
		match node.name:
			"THead": 
				head_target = node if head_target == null else head_target
			"TBody": 
				body_target = node if body_target == null else body_target
			"THandL": 
				hand_l_target = node if hand_l_target == null else hand_l_target
			"THandR": 
				hand_r_target = node if hand_r_target == null else hand_r_target
			"TFootL": 
				foot_l_target = node if foot_l_target == null else foot_l_target
			"TFootR": 
				foot_r_target = node  if foot_r_target == null else foot_r_target
	
	if node is SkeletonIK3D:
		if node.get_parent() != skeleton:
			node.reparent(skeleton)
		match node.name:
			"IK_Head": 
				head_ik = node if head_ik == null else head_ik
			"IK_Body": 
				body_ik = node if body_ik == null else body_ik	
			"IK_HandL": 
				hand_l_ik = node if hand_l_ik == null else hand_l_ik
			"IK_HandR": 
				hand_r_ik = node if hand_r_ik == null else hand_r_ik
			"IK_FootL": 
				foot_l_ik = node if foot_l_ik == null else foot_l_ik	
			"IK_FootR": 
				foot_r_ik = node if foot_r_ik == null else foot_r_ik
	
	if node is RayCast3D:
		match node.name:
			"IK_Ray_FootL": 
				foot_l_ray = node if foot_l_ray == null else foot_l_ray
			"IK_Ray_FootR": 
				foot_r_ray = node if foot_r_ray == null else foot_r_ray
	
	if node is BoneAttachment3D:
		node.reparent(skeleton)	
		
	for child in node.get_children():
		_setup_tree(child)
	
	pass
	
func _process(delta):
	# TEST CODE !
	if character.phys_interaction.current_hand_manipulation_target != null:
		_hand_l_ik_target_interpolation = 1
		_hand_r_ik_target_interpolation = 1
	else:
		_hand_l_ik_target_interpolation = 0
		_hand_r_ik_target_interpolation = 0
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _inited:
		_process_foot_ik(delta)
		_process_hands_ik(delta)
		_process_body_ik(delta)
		_update_state(delta)
	pass

func _process_hands_ik(delta):
	pass

func _process_body_ik(delta):
	if body_ik_enabled:
		print('kek')
		body_ik.interpolation = lerpf(body_ik.interpolation, min(body_target_interpolation, body_ik_interpolation_max), 0.1)
		body_target.rotation_degrees.y = move_toward(body_target.rotation_degrees.y, body_target_rotation_y, 90 * delta)
		body_target.rotation_degrees.x = move_toward(body_target.rotation_degrees.x, body_target_rotation_x, 90 * delta)
		body_target.rotation_degrees.z = move_toward(body_target.rotation_degrees.z, body_target_rotation_z, 90 * delta)
		#body_target.rotation_degrees.y = body_target_rotation_y

func _process_foot_ik(delta):
	if foot_ik_enabled:
		foot_l_ray.global_position = Vector3(
			foot_l_bone_tracker.global_position.x,
			foot_l_bone_tracker.global_position.y + 1,
			foot_l_bone_tracker.global_position.z,
		)
		
		foot_r_ray.global_position = Vector3(
			foot_r_bone_tracker.global_position.x,
			foot_r_bone_tracker.global_position.y + 1,
			foot_r_bone_tracker.global_position.z,
		)
		
		if character.is_touching_floor():
			if foot_l_ray.is_colliding():
				var point = foot_l_ray.get_collision_point()
				_foot_l_target_offset = clampf(point.y - global_position.y, 0, 1)
				_foot_ik_target_interpolation = foot_ik_interpolation_max
			else:
				_foot_l_target_offset = 0
				_foot_ik_target_interpolation = 0
				
			if foot_r_ray.is_colliding():
				var point = foot_r_ray.get_collision_point()
				_foot_r_target_offset =  clampf(point.y - global_position.y, 0, 1)
				_foot_ik_target_interpolation = foot_ik_interpolation_max
			else:
				_foot_r_target_offset = 0
				_foot_ik_target_interpolation= 0
			pass
			
			if max(_foot_l_target_offset, _foot_r_target_offset, 0) < 0.1:
				_foot_ik_target_interpolation = 0
			
		else:
			_foot_ik_target_interpolation = 0
		
func _update_state(delta):
	if foot_ik_enabled:
		foot_l_target.global_position.y = lerpf(foot_l_target.global_position.y, global_position.y + _foot_l_target_offset, 0.1)
		foot_r_target.global_position.y = lerpf(foot_r_target.global_position.y, global_position.y + _foot_r_target_offset, 0.1)
		
		foot_l_ik.interpolation = lerpf(foot_l_ik.interpolation, _foot_ik_target_interpolation, 0.1)
		foot_r_ik.interpolation = lerpf(foot_r_ik.interpolation, _foot_ik_target_interpolation, 0.1)
		
	if hands_ik_enabled:
		hand_l_ik.interpolation = lerpf(hand_l_ik.interpolation, _hand_l_ik_target_interpolation, 0.1)
		hand_r_ik.interpolation = lerpf(hand_r_ik.interpolation, _hand_r_ik_target_interpolation, 0.1)
	
