extends GameCharacterBodyController

class_name GameCharacterBodyControllerSkeletonBasic

@export_subgroup("Skeletong Pin Points to Bone Attachment")
@export var head_bone_name: String = "mixamorig_Head"
@export var hand_bone_name: String = "mixamorig_RightHand"
@export var chest_bone_name: String = "mixamorig_Spine"
@export var eyes_pin_point_offset: float = 0.25

@export_subgroup("Transitions and Blending")
@export var vertical_blend_transition_speed: float = 4
@export var horizontal_blend_transition_speed: float = 8

@export_subgroup("Extras")
@export var force_looping_for_animations: Array[String] = [
	"UnarmedIdle",
	"UnarmedWalk",
	"UnarmedSprint",
	"UnarmedFall",
	"UnarmedCrouchIdle",
	"UnarmedCrouchWalk",
	"UnarmedClimb"
]

@export var walk_animation_speed_scale: float = 1
@export var sprint_animation_speed_scale: float = 1
@export var sprint_animation_seek_offset: float = 0
@export var crouch_walk_animation_speed_scale: float = 1
@export var climb_animation_speed_scale: float = 1

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

func _ready():
	super._ready()
	
	
	# forcing loop mode for specified animations
	if _animation_player != null:
		for anim_name in force_looping_for_animations:
			var anim: Animation = _animation_player.get_animation(anim_name)
			anim.set_loop_mode(Animation.LOOP_LINEAR)
	

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
	_current_h_blend_value = move_toward(_current_h_blend_value, _target_h_blend_value, horizontal_blend_transition_speed * delta)
	_current_v_blend_value = move_toward(_current_v_blend_value, _target_v_blend_value, vertical_blend_transition_speed * delta)
			
	_current_h_speed_scale = move_toward(_current_h_speed_scale, _target_h_speed_scale, horizontal_blend_transition_speed * delta)
	_current_v_speed_scale = move_toward(_current_v_speed_scale, _target_v_speed_scale, vertical_blend_transition_speed * delta)


func _update_animation_tree(delta):
	_animation_tree["parameters/conditions/move"] = current_action_type == ECharacterBodyActionType.Move
	_animation_tree["parameters/conditions/climb"] = current_action_type == ECharacterBodyActionType.Climb
	
	match current_action_type:
		ECharacterBodyActionType.Move:
			_target_h_blend_value = lerpf(-1, 1, clampf((_current_character_h_velocity + _current_character_directional_velocity * directional_velocity_factor) / character.props.sprint_speed_max, 0, 1))
			_target_v_blend_value = -1 if character.is_crouching else 0
			
			if not character.is_touching_floor():
				_target_v_blend_value = sqrt(clampf((abs(character.air_time) / 2
				), 0, 1))
			
			_target_h_speed_scale = 1
			_target_v_speed_scale = 1
			
			_animation_tree["parameters/move/blend_position"] = Vector2(
				_current_h_blend_value,
				_current_v_blend_value
			)
			
			var move_direction_factor = -1 if _current_character_move_direction_factor < 0 else 1
			
			_animation_tree["parameters/move/2/TimeScale/scale"] = _current_h_speed_scale * walk_animation_speed_scale * move_direction_factor
			_animation_tree["parameters/move/3/TimeScale/scale"] = _current_h_speed_scale * sprint_animation_speed_scale * move_direction_factor
			_animation_tree["parameters/move/4/TimeScale/scale"] = _current_h_speed_scale * crouch_walk_animation_speed_scale * move_direction_factor
		
			_animation_tree["parameters/move/3/TimeSeek/seek_request"] = sprint_animation_seek_offset
		
		ECharacterBodyActionType.Climb:
			_animation_tree["parameters/climb/TimeScale 2/scale"] = _current_climb_animation_speed_scale * climb_animation_speed_scale
