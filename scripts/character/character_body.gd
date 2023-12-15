extends CollisionShape3D

class_name GameCharacterBody

enum ECharacterBodyAnimationCategory {
	Basic,
	Climbing
}

@export_subgroup("Pin Points")
@export var head_pin_point: Node3D
@export var eyes_pin_point: Node3D
@export var hand_pin_point: Node3D
@export var chest_pin_point: Node3D

@export_subgroup("Skeleton Animations")
@export var walk_animation_speed_scale: float = 1
@export var sprint_animation_speed_scale: float = 1
@export var crouch_walk_animation_speed_scale: float = 1
@export var climb_animation_speed_scale: float = 1

var character: GameCharacter
var _animation_tree: AnimationTree
var _animation_player: AnimationPlayer
var _skeleton: Skeleton3D

var _current_character_h_velocity: float = 0
var _current_character_v_velocity: float = 0
var _current_character_total_velocity: float = 0

var _basic_target_v_blend_pos: float = 0
var _basic_target_h_blend_pos: float = 0
var _basic_current_v_blend_pos: float = 0
var _basic_current_h_blend_pos: float = 0

var _current_climb_animation_speed_scale: float = 1

var _animation_category: ECharacterBodyAnimationCategory = ECharacterBodyAnimationCategory.Basic

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_tree(self)
	
	if _animation_tree != null:
		_animation_tree["parameters/Basic/5/TimeScale/scale"] = walk_animation_speed_scale
		_animation_tree["parameters/Basic/6/TimeScale/scale"] = sprint_animation_speed_scale
		_animation_tree["parameters/Basic/7/TimeScale/scale"] = crouch_walk_animation_speed_scale
		_animation_tree["parameters/Climbing/TimeScale 2/scale"] = climb_animation_speed_scale
	
	pass # Replace with function body.

func _setup_tree(node):
	# Call the callback function on the current node
	
	if node is AnimationPlayer:
		_animation_player = node
		
	if node is AnimationTree:
		_animation_tree = node
		_animation_tree.active = true
	
	if node is Skeleton3D:
		_skeleton = node
		
	# Recursively call this function on all children
	for child in node.get_children():
		_setup_tree(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if character != null and _animation_tree != null:
		_update_animation_params(delta)
		_update_animation_tree(delta)
	pass

func _update_animation_params(delta):
	_animation_category = ECharacterBodyAnimationCategory.Basic
	
	_current_character_h_velocity = Vector2(character.velocity.x, character.velocity.z).length()
	_current_character_v_velocity = character.velocity.y
	_current_character_total_velocity = character.velocity.length()
	
	if character.is_climbing:
		_animation_category = ECharacterBodyAnimationCategory.Climbing
	
	match _animation_category:
		ECharacterBodyAnimationCategory.Basic:
			
			_basic_target_h_blend_pos = lerpf(-1, 1, clampf(_current_character_h_velocity / character.props.sprint_speed_max, 0, 1))
			
			_basic_target_v_blend_pos = 0 if character.is_touching_floor() else 1
			_basic_target_v_blend_pos = -1 if character.is_crouching else _basic_target_v_blend_pos
			
			_basic_current_h_blend_pos = move_toward(_basic_current_h_blend_pos, _basic_target_h_blend_pos, 4 * delta)
			_basic_current_v_blend_pos = move_toward(_basic_current_v_blend_pos, _basic_target_v_blend_pos, 8 * delta)
			
		ECharacterBodyAnimationCategory.Climbing:
			_current_climb_animation_speed_scale = sqrt(clampf(abs(_current_character_total_velocity) / 3, 0, 1))

func _update_animation_tree(delta):
	_animation_tree["parameters/conditions/basic"] = _animation_category == ECharacterBodyAnimationCategory.Basic
	_animation_tree["parameters/conditions/climbing"] = _animation_category == ECharacterBodyAnimationCategory.Climbing
	
	
	
	match _animation_category:
		ECharacterBodyAnimationCategory.Basic:
			_animation_tree["parameters/Basic/blend_position"] = Vector2(
				_basic_current_h_blend_pos,
				_basic_current_v_blend_pos
			)
			
		ECharacterBodyAnimationCategory.Climbing:
			_animation_tree["parameters/Climbing/TimeScale 2/scale"] = climb_animation_speed_scale * _current_climb_animation_speed_scale
			pass
	
	

