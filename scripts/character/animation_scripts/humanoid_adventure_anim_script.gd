extends GameCharacterBodyAnimationScript

class_name GameCharacterBodyAnimationScriptMK0

@export var body_scene_root_node: Node3D

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
var _horizontal_velocity_total_interpolated: float = 0
var _vertical_velocity_total_interpolated: float = 0

@export var walk_animation_scale: float = 1.5
@export var sprint_animation_scale: float = 1.5

@export var back_walk_animation_scale: float = 1
@export var back_sprint_animation_scale: float = 1

@export var body_twist_max_angle: float = 90
@export var body_bend_max_angle: float = 10
@export var body_tilt_max_angle: float = 10

@export var body_crouched_twist_max_angle: float = 25
@export var body_crouched_bend_angle: float = 5
@export var body_crouched_tilt_max_angle: float = 5

@export_subgroup("Transitions and Blending")
@export var vertical_blend_transition_speed: float = 2
@export var horizontal_blend_transition_speed: float = 8

func on_setup():
	assert(animation_tree != null, "GameCharacterBodyAnimationScriptMK1: animation_tree is required to function")
	assert(animation_player != null, "GameCharacterBodyAnimationScriptMK1: animation_player is required to function")
	
	pass
	
func _process(delta):
	var bc = body_controller
	var character = bc.character
	
	animation_tree["parameters/main_scale/scale"] = game.speed
	
	_current_h_blend_value = move_toward(_current_h_blend_value, _target_h_blend_value, horizontal_blend_transition_speed * delta)
	_current_v_blend_value = move_toward(_current_v_blend_value, _target_v_blend_value, vertical_blend_transition_speed * delta)
			
	_current_h_speed_scale = move_toward(_current_h_speed_scale, _target_h_speed_scale, horizontal_blend_transition_speed * delta)
	_current_v_speed_scale = move_toward(_current_v_speed_scale, _target_v_speed_scale, vertical_blend_transition_speed * delta)
	
	_directional_velocity_factor_interpolated = move_toward(_directional_velocity_factor_interpolated, clampf(bc._current_character_directional_velocity, -1, 1), 4 * delta)

	animation_tree["parameters/main/conditions/basic"] = bc.current_action_type == GameCharacterBodyController.ECharacterBodyActionType.Move
	animation_tree["parameters/main/conditions/climb"] = bc.current_action_type == GameCharacterBodyController.ECharacterBodyActionType.Climb
	
	# OBJECT HOLDING
	match bc.current_action_type:
		GameCharacterBodyController.ECharacterBodyActionType.Move:
			#_current_character_directional_velocity
			
			var directional_velocity_factor = _directional_velocity_factor_interpolated
			var horizontal_velocity_total: float = _horizontal_velocity_total_interpolated
			
			_target_h_blend_value = lerpf(-1, 1, character.get_horizontal_speed_progress())
			
			if _target_h_blend_value < 0:
				_target_h_blend_value = clamp(_target_h_blend_value + abs(directional_velocity_factor) / 2, -1, 0)
			
			_target_v_blend_value = -1 if character.is_crouching else 0
			
			if not character.is_touching_floor():
				_target_v_blend_value = sqrt(clampf((abs(character.air_time) / 2
				), 0, 1))
			
			_target_h_speed_scale = 1
			_target_v_speed_scale = 1
			
			animation_tree["parameters/main/basic/blend_position"] = Vector2(
				_current_h_blend_value,
				_current_v_blend_value
			)
			
			var fx: float = character.move_to_body_direction_factor.x
			var fz: float = character.move_to_body_direction_factor.z
			
			fx = _move_to_direction_factor_interpolated.x
			fz = _move_to_direction_factor_interpolated.y
			
			fx -= lerpf(directional_velocity_factor * 0.75, 0, sqrt(character.get_horizontal_speed_progress())) 
			fx = clamp(fx, -1, 1)
			
			var max_twist_angle: float = body_crouched_twist_max_angle if character.is_crouching else body_twist_max_angle
			var max_bend_angle = body_bend_max_angle
			var min_bend_angle = -body_bend_max_angle
			var max_tilt_angle: float = body_crouched_tilt_max_angle if character.is_crouching else body_tilt_max_angle
			
			if character.is_crouching:
				max_bend_angle = body_crouched_bend_angle
				min_bend_angle = body_crouched_bend_angle
			
			var x_factor: float = ((tools.polarity(fx) * pow(fx, 2)) + 1) / 2
			var z_factor: float = (fz + 1) / 2
			
			
			if fz >= -0.1:
				body_scene_root_node.rotation_degrees.y = move_toward(body_scene_root_node.rotation_degrees.y, lerpf(max_twist_angle, -max_twist_angle, x_factor), 360 * delta)
				bc.ik_controller.body_target_rotation_y = lerpf(-10, 10, x_factor)
			else:
				body_scene_root_node.rotation_degrees.y = move_toward(body_scene_root_node.rotation_degrees.y, lerpf(-max_twist_angle, max_twist_angle, x_factor) , 360 * delta)
				bc.ik_controller.body_target_rotation_y = lerpf(10, -10, x_factor)
			
			bc.ik_controller.body_target_rotation_x = lerpf(-max_bend_angle, max_bend_angle, z_factor)
			bc.ik_controller.body_target_rotation_z = lerpf(-max_tilt_angle, max_tilt_angle, x_factor)
			
			if fz < -0.1:
				animation_tree["parameters/main/basic/2/walk_scale/scale"] = -1 * back_walk_animation_scale
				animation_tree["parameters/main/basic/3/run_scale/scale"] = -1 * back_sprint_animation_scale
				animation_tree["parameters/main/basic/4/crouch_walk_scale/scale"] = -1
			else:
				animation_tree["parameters/main/basic/2/walk_scale/scale"] = walk_animation_scale
				animation_tree["parameters/main/basic/3/run_scale/scale"] = sprint_animation_scale
				animation_tree["parameters/main/basic/4/crouch_walk_scale/scale"] = 1
			
			bc.ik_controller.body_target_interpolation = 0.5
			
		GameCharacterBodyController.ECharacterBodyActionType.Climb:
			var fx: float = character.move_to_body_direction_factor.x
			var fz: float = character.move_to_body_direction_factor.z
			
			fx = _move_to_direction_factor_interpolated.x
			fz = _move_to_direction_factor_interpolated.y
			
			var max_twist_angle: float = body_twist_max_angle
			var max_bend_angle = body_bend_max_angle
			var min_bend_angle = -body_bend_max_angle
			var max_tilt_angle: float = body_tilt_max_angle
			
			if fz >= -0.1:
				body_scene_root_node.rotation_degrees.y = move_toward(body_scene_root_node.rotation_degrees.y, lerpf(max_twist_angle, -max_twist_angle, (fx + 1) / 2), 180 * delta)
				bc.ik_controller.body_target_rotation_y = lerpf(-10, 10, (fx + 1) / 2)
			else:
				body_scene_root_node.rotation_degrees.y = move_toward(body_scene_root_node.rotation_degrees.y, lerpf(-max_twist_angle, max_twist_angle, (fx + 1) / 2) , 180 * delta)
				bc.ik_controller.body_target_rotation_y = lerpf(10, -10, (fx + 1) / 2)
			
			bc.ik_controller.body_target_rotation_x = lerpf(-max_bend_angle, max_bend_angle, (fz + 1) / 2)
			bc.ik_controller.body_target_rotation_z = lerpf(-max_tilt_angle, max_tilt_angle, (fx + 1) / 2)
			
			animation_tree["parameters/main/climb/climb_scale/scale"] = _vertical_velocity_total_interpolated / 5
			
			#body_scene_root_node.rotation_degrees.y = 0
			#bc.ik_controller.body_target_rotation_x = 0
			#bc.ik_controller.body_target_rotation_y = 0
			#bc.ik_controller.body_target_rotation_z = 0
			#
			#bc.ik_controller.body_target_interpolation = 0
			
			pass
	pass
	pass
	
func _physics_process(delta):
	if body_controller == null:
		return
		
	var bc = body_controller
	var character = bc.character
	
	var interp_velocity = 8
	#interp_velocity = 4
	_move_to_direction_factor_interpolated.x = move_toward(_move_to_direction_factor_interpolated.x, character.move_to_body_direction_factor.x, interp_velocity * delta)
	_move_to_direction_factor_interpolated.y = move_toward(
		_move_to_direction_factor_interpolated.y, 
		character.move_to_body_direction_factor.z, 
		interp_velocity * delta)
		
	_horizontal_velocity_total_interpolated = tools.lerpt(_horizontal_velocity_total_interpolated, bc._current_character_h_velocity + abs(
		pow(abs(bc._current_character_directional_velocity), 1)
	), 0.1)
	
	_vertical_velocity_total_interpolated = tools.lerpt(_vertical_velocity_total_interpolated, bc._current_character_v_velocity, 0.1)

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
