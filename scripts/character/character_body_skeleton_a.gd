extends GameCharacterBody

class_name GameCharacterBodyControllerSkeletonA

enum ECharacterBodyStance {
	Unarmed,
	Rifle2H,
	Pistol2H,
	Bow
}

enum ECharacterBodyActionType {
	Move,
	Climb,
	Fire
}

@export_subgroup("Skeleton Animations")
@export var walk_animation_speed_scale: float = 1
@export var sprint_animation_speed_scale: float = 1
@export var crouch_walk_animation_speed_scale: float = 1
@export var climb_animation_speed_scale: float = 1

@export_subgroup("Skeletong Pin Points to Bone Attachment")
@export var head_bone_name: String = "mixamorig_Head"
@export var hand_bone_name: String = "mixamorig_RightHand"
@export var chest_bone_name: String = "mixamorig_Spine"
@export var eyes_pin_point_offset: float = 0.25

var _animation_tree: AnimationTree
var _skeleton: Skeleton3D

var _current_character_h_velocity: float = 0
var _current_character_v_velocity: float = 0
var _current_character_total_velocity: float = 0

var _target_v_blend_value: float = 0
var _target_h_blend_value: float = 0
var _current_v_blend_value: float = 0
var _current_h_blend_value: float = 0

var _current_v_speed_scale: float = 1
var _current_h_speed_scale: float = 1
var _target_v_speed_scale: float = 1
var _target_h_speed_scale: float = 1

var _target_landing_impact_value: float = 0
var _current_landing_impact_value: float = 0

var _current_climb_animation_speed_scale: float = 1
var _stance: ECharacterBodyStance = ECharacterBodyStance.Unarmed
var _action_type: ECharacterBodyActionType = ECharacterBodyActionType.Move
var _anim_state_id: String = ""

var _prev_is_touching_floor: bool = false
var _is_touching_floor_changed: bool = false
var _jump_prepare_value: float = 0
var _current_landing_impact: float = 0

var _current_body_rotation: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	_check_bone_attachments()
	pass # Replace with function body.

func process(delta):
	super._process(delta)

func _check_bone_attachments():
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
		
func _setup_tree(node): 
	super._setup_tree(node)
	
	if node is AnimationTree:
		_animation_tree = node
		_animation_tree.active = true
	
	if node is Skeleton3D:
		_skeleton = node
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _update_body_state(delta):
	if character != null and _animation_tree != null:
		_update_animation_params(delta)
		_update_animation_tree(delta)
	pass

func _update_animation_params(delta):
	_current_landing_impact_value = move_toward(_current_landing_impact_value, _target_landing_impact_value, 1 * delta)
	
	_current_character_h_velocity = Vector2(character.velocity.x, character.velocity.z).length()
	_current_character_v_velocity = character.velocity.y
	_current_character_total_velocity = character.velocity.length()
	
	if character.is_climbing:
		_action_type = ECharacterBodyActionType.Climb
	else:
		_action_type = ECharacterBodyActionType.Move
	
	_anim_state_id = _get_animation_state_id(_stance, _action_type)
	
	_current_h_blend_value = move_toward(_current_h_blend_value, _target_h_blend_value, 8 * delta)
	_current_v_blend_value = move_toward(_current_v_blend_value, _target_v_blend_value, 8 * delta)
			
	_current_h_speed_scale = move_toward(_current_h_speed_scale, _target_h_speed_scale, 8 * delta)
	_current_v_speed_scale = move_toward(_current_v_speed_scale, _target_v_speed_scale, 8 * delta)
	
	_current_landing_impact = move_toward(_current_landing_impact, 0, 2 * delta)

func _update_animation_tree(delta):
	#for cond in _animation_tree["parameters/conditions"].keys:
		#print(cond)
	_animation_tree["parameters/conditions/unarmed_move"] = _anim_state_id == "unarmed_move"
	_animation_tree["parameters/conditions/unarmed_climb"] = _anim_state_id == "unarmed_climb"
	
	match _anim_state_id:
		"unarmed_move":
			_target_h_blend_value = lerpf(-1, 1, clampf(_current_character_h_velocity / character.props.sprint_speed_max, 0, 1))
			_target_v_blend_value = -1 if character.is_crouching else 0
			
			if not character.is_touching_floor():
				_target_v_blend_value = sqrt(clampf((abs(character.air_time) / 2
				), 0, 1))
			else:
				if character.jump_started:
					_target_v_blend_value -= 0.5 * (character.current_jump_charge / character.props.jump_max_charge_duration)
					pass
					
			if _current_landing_impact > 0:
				_current_h_blend_value = -0.5 * _current_landing_impact	
				_target_v_blend_value -= 0.5 * _current_landing_impact
			
			_target_h_speed_scale = 1
			_target_v_speed_scale = 1
			
			
			_animation_tree["parameters/unarmed_move/blend_position"] = Vector2(
				_current_h_blend_value,
				_current_v_blend_value
			)
			
			_animation_tree["parameters/unarmed_move/2/TimeScale/scale"] = _current_h_speed_scale * walk_animation_speed_scale
			_animation_tree["parameters/unarmed_move/3/TimeScale/scale"] = _current_h_speed_scale * sprint_animation_speed_scale
	
			_animation_tree["parameters/unarmed_move/4/TimeScale/scale"] = _current_h_speed_scale * crouch_walk_animation_speed_scale
	
			
	
	#_animation_tree["parameters/conditions/unarmed_climb"] = _animation_category == ECharacterBodyStance.Unarmed
	#_animation_tree["parameters/conditions/climbing"] = _animation_category == ECharacterBodyStance.Climb
	
	
	
	#match _animation_category:
		#ECharacterBodyStance.Unarmed:
			#_animation_tree["parameters/Unarmed/blend_position"] = Vector2(
				#_current_h_blend_value,
				#_current_v_blend_value
			#)
			#
		#ECharacterBodyStance.Climb:
			#_animation_tree["parameters/Climb/TimeScale 2/scale"] = climb_animation_speed_scale * _current_climb_animation_speed_scale
			#pass
	
func _get_stance_id(stance: ECharacterBodyStance):
	match stance:
		ECharacterBodyStance.Unarmed:
			return "unarmed"
		ECharacterBodyStance.Rifle2H:
			return "rifle2h"
		ECharacterBodyStance.Pistol2H:
			return "pistol2h"
		ECharacterBodyStance.Bow:
			return "bow"
		_:
			return "unarmed"

func _get_action_type_id(action_type: ECharacterBodyActionType):
	match action_type:
		ECharacterBodyActionType.Move:
			return "move"
		ECharacterBodyActionType.Climb:
			return "climb"
		ECharacterBodyActionType.Fire:
			return "fire"
		_:
			return "move"

func _get_animation_state_id(stance:ECharacterBodyStance, action_type: ECharacterBodyActionType)-> String:
	return _get_stance_id(stance) + "_" + _get_action_type_id(action_type)

func commit_landing(impact_power: float = 0):
	_current_landing_impact = impact_power
