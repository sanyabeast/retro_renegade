extends CollisionShape3D

class_name GameCharacterBodyController

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

@export_subgroup("Pin Points")
@export var head_pin_point: Node3D
@export var eyes_pin_point: Node3D
@export var hand_pin_point: Node3D
@export var chest_pin_point: Node3D

var character: GameCharacter
var _animation_player: AnimationPlayer
var _animation_tree: AnimationTree
var _skeleton: Skeleton3D

var _current_character_h_velocity: float = 0
var _current_character_v_velocity: float = 0
var _current_character_total_velocity: float = 0
var _current_character_directional_velocity: float = 0


# Stances and Actions
var current_stance: ECharacterBodyStance = ECharacterBodyStance.Unarmed
var current_action_type: ECharacterBodyActionType = ECharacterBodyActionType.Move

var _prev_body_direction: Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_tree(self)
	_setup_pin_points()
	
	if character != null:
		initialize()
	
	pass # Replace with function body.

func initialize():
	pass

func _setup_pin_points():
	if head_pin_point == null:
		head_pin_point = self
	if hand_pin_point == null:
		hand_pin_point = self
	if chest_pin_point == null:
		chest_pin_point = self
	pass

func _setup_tree(node):
	if node is AnimationPlayer:
		_animation_player = node
		
	if node is AnimationTree:
		_animation_tree = node
		_animation_tree.active = true
	
	if node is Skeleton3D:
		_skeleton = node	

	for child in node.get_children():
		_setup_tree(child)

func _process(delta):
	_current_character_h_velocity = Vector2(character.velocity.x, character.velocity.z).length()
	_current_character_v_velocity = character.velocity.y
	_current_character_total_velocity = character.velocity.length()
	_current_character_directional_velocity = _prev_body_direction.distance_to(character.global_transform.basis.z)
	
	# Stance and action
	if character.is_climbing:
		current_action_type = ECharacterBodyActionType.Climb
	else:
		current_action_type = ECharacterBodyActionType.Move
	
	_update_body_state(delta)
	
	_prev_body_direction = character.global_transform.basis.z
	pass

func commit_landing(impact_power: float = 0):
	pass

func _update_body_state(delta):
	pass


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

func _get_animation_state_id(stance: ECharacterBodyStance, action_type: ECharacterBodyActionType)-> String:
	return _get_stance_id(stance) + "_" + _get_action_type_id(action_type)


# BODY PHYSICS
func add_collision_exception_for_body_physics(node)->void:
	if node != character:
		character.add_collision_exception_with(node)
	pass

func remove_collision_exception_for_body_physics(node)->void:
	if node != character:
		character.remove_collision_exception_with(node)
	pass

func get_physics_body_anchor_transform()->Transform3D:
	return character.global_transform

func start_body_physics():
	pass
	
func stop_body_physics():
	pass

