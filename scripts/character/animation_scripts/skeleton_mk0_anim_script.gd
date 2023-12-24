extends GameCharacterBodyAnimationScript

class_name GameCharacterBodyAnimationScriptMK0

@export var move_animation_speed_scale: float = 1.5
@export var body_scene_root_node: Node3D
@export var body_twist_max_angle: float = 70
@export var body_bend_max_angle: float = 15
@export var body_tilt_max_angle: float = 10

@export var body_crouched_twist_max_angle: float = 25
@export var body_crouched_bend_angle: float = 15
@export var body_crouched_tilt_max_angle: float = 5

@export_subgroup("Animation Style")
@export var walk_style: float = 0
@export var run_style: float = 0
@export var idle_style: float = 0
@export var crouch_idle_style: float = 0
@export var fall_style: float = 0

@export_subgroup("Transitions and Blending")
@export var vertical_blend_transition_speed: float = 4
@export var horizontal_blend_transition_speed: float = 8

@export_subgroup("Extras")
@export var force_looping_for_animations: Array[String] = [
	"Idle",
	"Walk",
	"Fall"
]

var _current_climb_animation_speed_scale: float = 1
var _move_to_direction_factor_interpolated: Vector2 = Vector2.UP

var _target_v_blend_value: float = 0
var _target_h_blend_value: float = 0
var _current_v_blend_value: float = 0
var _current_h_blend_value: float = 0

var _current_v_speed_scale: float = 1
var _current_h_speed_scale: float = 1
var _target_v_speed_scale: float = 1
var _target_h_speed_scale: float = 1

var _directional_velocity_factor_interpolated: float = 0

func on_setup():
	assert(animation_tree != null, "GameCharacterBodyAnimationScriptMK1: animation_tree is required to function")
	assert(animation_player != null, "GameCharacterBodyAnimationScriptMK1: animation_player is required to function")
	
	# forcing loop mode for specified animations
	if animation_player != null:
		for anim_name in force_looping_for_animations:
			var anim: Animation = animation_player.get_animation(anim_name)
			if anim != null:
				anim.set_loop_mode(Animation.LOOP_LINEAR)
	
	pass
	
func _process(delta):
	var bc = body_controller
	var character = bc.character
	
	_current_h_blend_value = move_toward(_current_h_blend_value, _target_h_blend_value, horizontal_blend_transition_speed * delta)
	_current_v_blend_value = move_toward(_current_v_blend_value, _target_v_blend_value, vertical_blend_transition_speed * delta)
			
	_current_h_speed_scale = move_toward(_current_h_speed_scale, _target_h_speed_scale, horizontal_blend_transition_speed * delta)
	_current_v_speed_scale = move_toward(_current_v_speed_scale, _target_v_speed_scale, vertical_blend_transition_speed * delta)
	
	_directional_velocity_factor_interpolated = move_toward(_directional_velocity_factor_interpolated, clampf(bc._current_character_directional_velocity, -1, 1), 16 * delta)

	animation_tree["parameters/conditions/move"] = bc.current_action_type == GameCharacterBodyController.ECharacterBodyActionType.Move
	animation_tree["parameters/conditions/climb"] = bc.current_action_type == GameCharacterBodyController.ECharacterBodyActionType.Climb
	
	# OBJECT HOLDING
	match bc.current_action_type:
		GameCharacterBodyController.ECharacterBodyActionType.Move:
			#_current_character_directional_velocity
			
			var directional_velocity_factor = _directional_velocity_factor_interpolated
			var horizontal_velocity_total: float = bc._current_character_h_velocity + abs(
				directional_velocity_factor * 2
			)
			
			_target_h_blend_value = lerpf(-1, 1, clampf((horizontal_velocity_total) / character.get_sprint_speed_max(), 0, 1))
			_target_v_blend_value = -1 if character.is_crouching else 0
			
			if not character.is_touching_floor():
				_target_v_blend_value = sqrt(clampf((abs(character.air_time) / 2
				), 0, 1))
			
			_target_h_speed_scale = 1
			_target_v_speed_scale = 1
			
			animation_tree["parameters/move/move_blend_space/blend_position"] = Vector2(
				_current_h_blend_value,
				_current_v_blend_value
			)
			
			var fx: float = character.move_to_body_direction_factor.x
			var fz: float = character.move_to_body_direction_factor.z
			
			fx = _move_to_direction_factor_interpolated.x
			fz = _move_to_direction_factor_interpolated.y
			
			fx += pow(directional_velocity_factor, 3) 
			fx = clamp(fx, -1, 1)
			
			var max_twist_angle: float = body_crouched_twist_max_angle if character.is_crouching else body_twist_max_angle
			var max_bend_angle = body_bend_max_angle
			var min_bend_angle = -body_bend_max_angle
			var max_tilt_angle: float = body_crouched_tilt_max_angle if character.is_crouching else body_tilt_max_angle
			
			if character.is_crouching:
				max_bend_angle = body_crouched_bend_angle
				min_bend_angle = body_crouched_bend_angle
			
			if fz >= -0.1:
				body_scene_root_node.rotation_degrees.y = move_toward(body_scene_root_node.rotation_degrees.y, lerpf(max_twist_angle, -max_twist_angle, (fx + 1) / 2), 180 * delta)
				bc.ik_controller.body_target_rotation_y = lerpf(-10, 10, (fx + 1) / 2)
			else:
				body_scene_root_node.rotation_degrees.y = move_toward(body_scene_root_node.rotation_degrees.y, lerpf(-max_twist_angle, max_twist_angle, (fx + 1) / 2) , 180 * delta)
				bc.ik_controller.body_target_rotation_y = lerpf(10, -10, (fx + 1) / 2)
			
			bc.ik_controller.body_target_rotation_x = lerpf(-max_bend_angle, max_bend_angle, (fz + 1) / 2)
			bc.ik_controller.body_target_rotation_z = lerpf(-max_tilt_angle, max_tilt_angle, (fx + 1) / 2)
			
			animation_tree["parameters/move/move_blend_space_scale/scale"] = (-1 if character.move_to_body_direction_factor.z < -0.1 else 1) * move_animation_speed_scale
			
			# STYLES
			animation_tree["parameters/move/move_blend_space/2/blend_position"] = walk_style
			animation_tree["parameters/move/move_blend_space/3/blend_position"] = run_style
			animation_tree["parameters/move/move_blend_space/4/blend_position"] = idle_style
			animation_tree["parameters/move/move_blend_space/5/blend_position"] = fall_style
			animation_tree["parameters/move/move_blend_space/6/blend_position"] = crouch_idle_style
			
			bc.ik_controller.body_target_interpolation = 0.5
			
		GameCharacterBodyController.ECharacterBodyActionType.Climb:
			body_scene_root_node.rotation_degrees.y = 0
			bc.ik_controller.body_target_rotation_x = 0
			bc.ik_controller.body_target_rotation_y = 0
			bc.ik_controller.body_target_rotation_z = 0
			
			bc.ik_controller.body_target_interpolation = 0
			
			pass
	pass
	pass
	
func _physics_process(delta):
	var bc = body_controller
	var character = bc.character
	
	_move_to_direction_factor_interpolated.x = lerpf(_move_to_direction_factor_interpolated.x, character.move_to_body_direction_factor.x, 0.025)
	_move_to_direction_factor_interpolated.y = lerpf(
		_move_to_direction_factor_interpolated.y, 
		character.move_to_body_direction_factor.z, 
		0.025)

	
	pass

func _handle_object_grab(object: Node3D):
	body_controller.ik_controller.set_hands_target_objects(
		body_controller.hold_anchor_left,
		body_controller.hold_anchor_right,
	)
	
func _handle_object_drop(object: Node3D):
	body_controller.ik_controller.set_hands_target_objects(null, null)

func _handle_object_throw(object: Node3D):
	body_controller.ik_controller.set_hands_target_objects(null, null)
