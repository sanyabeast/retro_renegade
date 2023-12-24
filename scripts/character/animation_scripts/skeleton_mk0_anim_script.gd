extends GameCharacterBodyAnimationScript

class_name GameCharacterBodyAnimationScriptMK0

@export var move_animation_speed_scale: float = 1.5
@export var body_scene_root_node: Node3D
@export var body_twist_max_angle: float = 75
@export var body_bend_max_angle: float = 15
@export var body_tilt_max_angle: float = 10

@export var body_crouched_twist_max_angle: float = 30
@export var body_crouched_bend_angle: float = 15

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

	#animation_tree["parameters/conditions/move"] = bc.current_action_type == GameCharacterBodyController.ECharacterBodyActionType.Move
	#animation_tree["parameters/conditions/climb"] = bc.current_action_type == GameCharacterBodyController.ECharacterBodyActionType.Climb
	
	
	# OBJECT HOLDING
	match bc.current_action_type:
		GameCharacterBodyController.ECharacterBodyActionType.Move:
			_target_h_blend_value = lerpf(-1, 1, clampf((bc._current_character_h_velocity) / character.get_sprint_speed_max(), 0, 1))
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
			
		
			#bc.ik_controller.body_target_rotation_y = lerpf(150, 210, (character.move_to_body_direction_factor.x + 1) / 2)
			
			var fx: float = character.move_to_body_direction_factor.x
			var fz: float = character.move_to_body_direction_factor.z
			
			fx = _move_to_direction_factor_interpolated.x
			fz = _move_to_direction_factor_interpolated.y
			
			var max_twist_angle: float = body_crouched_twist_max_angle if character.is_crouching else body_twist_max_angle
			var max_bend_angle = body_bend_max_angle
			var min_bend_angle = -body_bend_max_angle
			
			if character.is_crouching:
				max_bend_angle = body_crouched_bend_angle
				min_bend_angle = body_crouched_bend_angle
			
			if fz >= -0.1:
				body_scene_root_node.rotation_degrees.y = move_toward(body_scene_root_node.rotation_degrees.y, lerpf(max_twist_angle, -max_twist_angle, (fx + 1) / 2), 180 * delta)
				bc.ik_controller.body_target_rotation_y = lerpf(160, 200, (fx + 1) / 2)
			else:
				body_scene_root_node.rotation_degrees.y = move_toward(body_scene_root_node.rotation_degrees.y, lerpf(-max_twist_angle, max_twist_angle, (fx + 1) / 2) , 180 * delta)
				bc.ik_controller.body_target_rotation_y = lerpf(200, 160, (fx + 1) / 2)
			
			bc.ik_controller.body_target_rotation_x = lerpf(-max_bend_angle, max_bend_angle, (fz + 1) / 2)
			bc.ik_controller.body_target_rotation_z = lerpf(-body_tilt_max_angle, body_tilt_max_angle, (fx + 1) / 2)
			
			animation_tree["parameters/move/move_blend_space_scale/scale"] = (-1 if character.move_to_body_direction_factor.z < -0.1 else 1) * move_animation_speed_scale
			
			#animation_tree["parameters/move_scaler/move_scale/scale"] = (-1 if character.move_to_body_direction_factor.z < 0 else 1) * move_animation_speed_scale
			
			# directional movement animations
			#animation_tree["parameters/move_scaler/move/5/move_direct/blend_position"] = _move_to_direction_factor_interpolated
			#animation_tree["parameters/move_scaler/move/6/run_direct/blend_position"] = _move_to_direction_factor_interpolated
		
		GameCharacterBodyController.ECharacterBodyActionType.Climb:
			#animation_tree["parameters/climb_scaler/climb/blend_position"] = Vector2(
				#character.move_to_body_direction_factor.x,
				#character.move_to_body_direction_factor.y
			#)
			#animation_tree["parameters/climb_scaler/climb_scale/scale"] = 1
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