extends GameCharacterBodyAnimationScript

class_name GameCharacterBodyAnimationScriptDefault


var _target_v_blend_value: float = 0
var _target_h_blend_value: float = 0
var _current_v_blend_value: float = 0
var _current_h_blend_value: float = 0

var _current_v_speed_scale: float = 1
var _current_h_speed_scale: float = 1
var _target_v_speed_scale: float = 1
var _target_h_speed_scale: float = 1

func _process(delta):
	var bc = body_controller
	var character = bc.character
	
	_current_h_blend_value = move_toward(_current_h_blend_value, _target_h_blend_value, 4 * delta)
	_current_v_blend_value = move_toward(_current_v_blend_value, _target_v_blend_value, 4 * delta)
			
	_current_h_speed_scale = move_toward(_current_h_speed_scale, _target_h_speed_scale, 4 * delta)
	_current_v_speed_scale = move_toward(_current_v_speed_scale, _target_v_speed_scale, 4 * delta)

	#animation_tree["parameters/conditions/move"] = bc.current_action_type == GameCharacterBodyController.ECharacterBodyActionType.Move
	#animation_tree["parameters/conditions/climb"] = bc.current_action_type == GameCharacterBodyController.ECharacterBodyActionType.Climb
	
	match bc.current_action_type:
		GameCharacterBodyController.ECharacterBodyActionType.Move:
			_target_h_blend_value = lerpf(-1, 1, clampf((bc._current_character_h_velocity) / character.get_sprint_speed_max(), 0, 1))
			_target_v_blend_value = -1 if character.is_crouching else 0
			
			if not character.is_touching_floor():
				_target_v_blend_value = sqrt(clampf((abs(character.air_time) / 2
				), 0, 1))
			
			animation_tree["parameters/move/move_blend_space/blend_position"] = Vector2(
				_current_h_blend_value,
				_current_v_blend_value
			)
			
		GameCharacterBodyController.ECharacterBodyActionType.Climb:
			pass
	pass
	pass
	
