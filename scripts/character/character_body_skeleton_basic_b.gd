extends GameCharacterBodyControllerSkeletonBasic

class_name GameCharacterBodyControllerSkeletonBasicB

@export_subgroup("Skeleton Basic [B]")
@export var move_animation_speed_scale: float = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	force_looping_for_animations = [
		"Idle",
		"Walk",
		"Run",
		"Freefall",
		"Crouch_Idle",
		"Crouch_Walk",
		"Climb_Up",
		"Climb_Down",
		"Climb_Right",
		"Ladder_Up",
		"StandUpFace"
	]
	
	super._ready()
	
	pass # Replace with function body.


func _update_animation_tree(delta):
	_animation_tree["parameters/conditions/move"] = current_action_type == ECharacterBodyActionType.Move
	_animation_tree["parameters/conditions/climb"] = current_action_type == ECharacterBodyActionType.Climb
	
	match current_action_type:
		ECharacterBodyActionType.Move:
			_target_h_blend_value = lerpf(-1, 1, clampf((_current_character_h_velocity) / character.props.sprint_speed_max, 0, 1))
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
		
			_animation_tree["parameters/move_scaler/move_scale/scale"] = (-1 if _move_to_body_direction_factor.z < 0 else 1) * move_animation_speed_scale
		
		ECharacterBodyActionType.Climb:
			_animation_tree["parameters/climb_scaler/climb/blend_position"] = Vector2(
				_move_to_body_direction_factor.x,
				_move_to_body_direction_factor.y
			)
			_animation_tree["parameters/climb_scaler/climb_scale/scale"] = 1
	pass
