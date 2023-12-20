extends Node3D


class_name GameCharacterBodyIKController

@export var skeleton: Skeleton3D
@export var character: GameCharacter

@export_subgroup("IK Systems")
@export var head_ik: SkeletonIK3D
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
		
		_foot_l_target_offset = global_position.y
		_foot_r_target_offset = global_position.y
		
		if foot_ik_enabled:
			foot_l_ik.start()
			foot_r_ik.start()
		
		foot_l_ray.add_exception(character)
		foot_r_ray.add_exception(character)
	pass

func _setup_tree(node):
	if node is Node3D and not node is SkeletonIK3D:
		match node.name:
			"THead": 
				head_target = node
			"TBody": 
				body_target = node
			"THandL": 
				hand_l_target = node	
			"THandR": 
				hand_r_target = node
			"TFootL": 
				foot_l_target = node	
			"TFootR": 
				foot_r_target = node
	
	if node is SkeletonIK3D:
		if node.get_parent() != skeleton:
			node.reparent(skeleton)
		match node.name:
			"IK_Head": 
				head_ik = node
			"IK_HandL": 
				hand_l_ik = node	
			"IK_HandR": 
				hand_r_ik = node
			"IK_FootL": 
				foot_l_ik = node	
			"IK_FootR": 
				foot_r_ik = node
	
	if node is RayCast3D:
		match node.name:
			"IK_Ray_FootL": 
				if foot_l_ray == null:
					foot_l_ray = node
			"IK_Ray_FootR": 
				if foot_r_ray == null:
					foot_r_ray = node
			
	for child in node.get_children():
		_setup_tree(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _inited:
		_process_foot_ik(delta)
		_update_state(delta)
	pass

func _process_foot_ik(delta):
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
	
