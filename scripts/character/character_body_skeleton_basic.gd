extends GameCharacterBodyController

class_name GameCharacterBodyControllerSkeletonBasic

@export_subgroup("Skeletong Pin Points to Bone Attachment")
@export var head_bone_name: String = "mixamorig_Head"
@export var hand_bone_name: String = "mixamorig_RightHand"
@export var chest_bone_name: String = "mixamorig_Spine"
@export var eyes_pin_point_offset: float = 0.25
@export var physics_body_anchor: Node3D

@export_subgroup("Transitions and Blending")
@export var vertical_blend_transition_speed: float = 4
@export var horizontal_blend_transition_speed: float = 8

@export_subgroup("IK")
@export var ik_controller: GameCharacterBodyIKController

@export_subgroup("Extras")
@export var force_looping_for_animations: Array[String] = [
	"Idle",
	"Walk",
	"Walk_StrafeLeft",
	"Walk_StrafeRight",
	"Walk_Backwards",
	"Run",
	"Run_StrafeLeft",
	"Run_StrafeRight",
	"Run_Backwards",
	"Freefall",
	"Crouch_Idle",
	"Crouch_Walk",
	"Climb_Up",
	"Climb_Down",
	"Climb_Right",
	"Ladder_Up",
	"StandUpFace"
]

@export var move_animation_speed_scale: float = 1.5

var directional_velocity_factor: float = 20

var _target_v_blend_value: float = 0
var _target_h_blend_value: float = 0
var _current_v_blend_value: float = 0
var _current_h_blend_value: float = 0

var _current_v_speed_scale: float = 1
var _current_h_speed_scale: float = 1
var _target_v_speed_scale: float = 1
var _target_h_speed_scale: float = 1

var _current_climb_animation_speed_scale: float = 1
var _move_to_direction_factor_interpolated: Vector2 = Vector2.UP

var _physical_bones: Array[PhysicalBone3D] = []
var _direction_switch_interpolation_speed: float = 3

func initialize():
	super.initialize()
	# forcing loop mode for specified animations
	if _animation_player != null:
		for anim_name in force_looping_for_animations:
			var anim: Animation = _animation_player.get_animation(anim_name)
			if anim != null:
				anim.set_loop_mode(Animation.LOOP_LINEAR)
				
	if ik_controller != null:
		if ik_controller.skeleton == null and _skeleton != null:
			ik_controller.skeleton = _skeleton
			ik_controller.character = character
			ik_controller.initialize()

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
	if character != null and _animation_tree != null:
		_update_animation_params(delta)
		_update_animation_tree(delta)
	pass

func _update_animation_params(delta):
	#_move_to_direction_factor_interpolated = _move_to_direction_factor_interpolated.move_toward(Vector2(
		#character.move_to_body_direction_factor.x,
		#character.move_to_body_direction_factor.z
	#), _direction_switch_interpolation_speed * delta)
	
	_move_to_direction_factor_interpolated.x = move_toward(_move_to_direction_factor_interpolated.x, character.move_to_body_direction_factor.x, 3.0 * delta)
	_move_to_direction_factor_interpolated.y = move_toward(_move_to_direction_factor_interpolated.y, character.move_to_body_direction_factor.z, 1.5 * delta)
	
	
	#_move_to_direction_factor_interpolated = _move_to_direction_factor_interpolated.lerp(Vector2(
		#character.move_to_body_direction_factor.x,
		#character.move_to_body_direction_factor.z
	#), 0.05)
	
	_current_h_blend_value = move_toward(_current_h_blend_value, _target_h_blend_value, horizontal_blend_transition_speed * delta)
	_current_v_blend_value = move_toward(_current_v_blend_value, _target_v_blend_value, vertical_blend_transition_speed * delta)
			
	_current_h_speed_scale = move_toward(_current_h_speed_scale, _target_h_speed_scale, horizontal_blend_transition_speed * delta)
	_current_v_speed_scale = move_toward(_current_v_speed_scale, _target_v_speed_scale, vertical_blend_transition_speed * delta)


func _update_animation_tree(delta):
	
	_animation_tree["parameters/conditions/move"] = current_action_type == ECharacterBodyActionType.Move
	_animation_tree["parameters/conditions/climb"] = current_action_type == ECharacterBodyActionType.Climb
	
	match current_action_type:
		ECharacterBodyActionType.Move:
			_target_h_blend_value = lerpf(-1, 1, clampf((_current_character_h_velocity) / character.get_sprint_speed_max(), 0, 1))
			_target_v_blend_value = -1 if character.is_crouching else 0
			
			if not character.is_touching_floor():
				_target_v_blend_value = sqrt(clampf((abs(character.air_time) / 2
				), 0, 1))
			
			_target_h_speed_scale = 1
			_target_v_speed_scale = 1
			
			_animation_tree["parameters/move_scaler/move/blend_position"] = Vector2(
				_current_h_blend_value,
				_current_v_blend_value
			)
		
			#_animation_tree["parameters/move_scaler/move_scale/scale"] = (-1 if character.move_to_body_direction_factor.z < 0 else 1) * move_animation_speed_scale
			
			# directional movement animations
			_animation_tree["parameters/move_scaler/move/5/walk_direct/blend_position"] = _move_to_direction_factor_interpolated
			_animation_tree["parameters/move_scaler/move/6/run_direct/blend_position"] = _move_to_direction_factor_interpolated
		
		ECharacterBodyActionType.Climb:
			_animation_tree["parameters/climb_scaler/climb/blend_position"] = Vector2(
				character.move_to_body_direction_factor.x,
				character.move_to_body_direction_factor.y
			)
			_animation_tree["parameters/climb_scaler/climb_scale/scale"] = 1
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
