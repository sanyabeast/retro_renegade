extends GameCharacterBodyController

class_name GameCharacterBodyControllerSkeletonBasic

@export_subgroup("Skeletong Pin Points to Bone Attachment")
@export var head_bone_name: String = "mixamorig_Head"
@export var hips_bone_name: String = "mixamorig_Hips"

@export_subgroup("IK")
@export var ik_controller: GameCharacterBodyIKController

var head_bone_tracker: BoneAttachment3D
var hips_bone_tracker: BoneAttachment3D

var _physical_bones: Array[PhysicalBone3D] = []
var _direction_switch_interpolation_speed: float = 3

func initialize(_character: GameCharacter):
	super.initialize(_character)
			
	if ik_controller != null:
		if ik_controller.skeleton == null and _skeleton != null:
			ik_controller.skeleton = _skeleton
			ik_controller.character = character
			ik_controller.initialize()
		else:
			dev.logr("GameCharacterBodyControllerSkeletonBasic", "ik_controller requires skeleton and character to be set up")
			
			

func add_collision_exception_for_body_physics(node)->void:
	for pbone in _physical_bones:
		character.add_collision_exception_with(pbone)

func _setup_tree(node):
	super._setup_tree(node)
	
	if node is PhysicalBone3D:
		_physical_bones.append(node)
			
	if node is GameCharacterBodyIKController:
		ik_controller = node

func _setup_anchors():
	if head_bone_name != "":
		head_bone_tracker = BoneAttachment3D.new()
		head_bone_tracker.bone_name = head_bone_name
		_skeleton.add_child(head_bone_tracker)
		
	if hips_bone_name != "":
		hips_bone_tracker = BoneAttachment3D.new()
		hips_bone_tracker.bone_name = hips_bone_name
		_skeleton.add_child(hips_bone_tracker)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _update_body_state(delta):
	head_anchor.global_position = head_bone_tracker.global_position
	hips_anchor.global_position = hips_bone_tracker.global_position
	
	pass

func start_body_physics():
	super.start_body_physics()
	dev.logd("GameCharacterBodyControllerSkeletonBasic", "body physics STARTED")
	_skeleton.physical_bones_start_simulation()
	
func stop_body_physics():
	super.stop_body_physics()
	dev.logd("GameCharacterBodyControllerSkeletonBasic", "body physics STOPPED")
	_skeleton.physical_bones_stop_simulation()

func get_physics_body_anchor_transform()-> Transform3D:
	if hips_bone_tracker != null:
		return hips_bone_tracker.global_transform
	else:
		return character.global_transform
