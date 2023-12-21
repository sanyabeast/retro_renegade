extends GameCharacterBodyController

class_name GameCharacterBodyControllerSkeletonBasic

@export_subgroup("Skeletong Pin Points to Bone Attachment")
@export var head_bone_name: String = "mixamorig_Head"
@export var hand_bone_name: String = "mixamorig_RightHand"
@export var chest_bone_name: String = "mixamorig_Spine"
@export var eyes_pin_point_offset: float = 0.25
@export var physics_body_anchor: Node3D

@export_subgroup("IK")
@export var ik_controller: GameCharacterBodyIKController

var _physical_bones: Array[PhysicalBone3D] = []
var _direction_switch_interpolation_speed: float = 3

func initialize():
	super.initialize()
			
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
		
		if physics_body_anchor == null:
			physics_body_anchor = node
			
	if node is GameCharacterBodyIKController:
		ik_controller = node

func _setup_pin_points():
	if head_pin_point == null and head_bone_name != "":
		head_pin_point = BoneAttachment3D.new()
		head_pin_point.bone_name = head_bone_name
		_skeleton.add_child(head_pin_point)
		eyes_pin_point = Node3D.new()
		eyes_pin_point.position.z = eyes_pin_point_offset
		head_pin_point.add_child(eyes_pin_point)
	if hand_pin_point == null and hand_bone_name != "":
		hand_pin_point = BoneAttachment3D.new()
		hand_pin_point.bone_name = hand_bone_name
		_skeleton.add_child(hand_pin_point)
	if chest_pin_point == null and chest_bone_name != "":
		chest_pin_point = BoneAttachment3D.new()
		chest_pin_point.bone_name = chest_bone_name	
		_skeleton.add_child(chest_pin_point)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _update_body_state(delta):
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
	if physics_body_anchor != null:
		return physics_body_anchor.global_transform
	else:
		return character.global_transform
