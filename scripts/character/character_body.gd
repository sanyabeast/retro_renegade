extends Node3D

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

@export var animation_script: GameCharacterBodyAnimationScript

@export_subgroup("Default Stance Collision")
@export var stand_collider_shape: Shape3D
@export var stand_collider_position: Vector3 = Vector3(0, 0.9, 0)

@export_subgroup("Crouch Stance Collision")
@export var crouch_collider_shape: Shape3D
@export var crouch_collider_position: Vector3 = Vector3(0, 0.45, 0)

@export_subgroup("Anchors")
@export var head_anchor: Node3D
@export var hips_anchor: Node3D

@export_subgroup("Eyes Anchor")
@export var eyes_anchor: Node3D
@export var eyes_anchor_offset: Vector3 = Vector3.FORWARD * 0.25

@export_subgroup("Hold Anchor")
@export var hold_anchor: Node3D
@export var hold_anchor_left: Node3D
@export var hold_anchor_right: Node3D
@export var hold_offset_crouch: float = 0.05
@export var hold_offset_stand: float = 0.6

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
	_setup_anchors()
	
	if character != null:
		initialize(character)
	
	pass # Replace with function body.

func initialize(_character: GameCharacter):
	character = _character
	
	add_collision_exception_for_body_physics(character)
	
	if animation_script != null:
		animation_script.initialize(self)
		
	character.on_crouch_entered.connect(_enable_character_crouch_collision)
	character.on_crouch_exited.connect(_enable_character_stand_collision)

	if eyes_anchor == null:
		eyes_anchor = Node3D.new()
		eyes_anchor.position = eyes_anchor_offset
		head_anchor.add_child(eyes_anchor)

func _setup_anchors():
	if head_anchor == null:
		head_anchor = self
	if hold_anchor == null:
		hold_anchor = self
	pass

func _setup_tree(node):
	if node is AnimationPlayer:
		_animation_player = node
		
	if node is AnimationTree:
		_animation_tree = node
		_animation_tree.active = true
	
	if node is Skeleton3D:
		_skeleton = node	

	if node is Node3D:
		match node.name:
			"HeadAnchor":
				head_anchor = node
			"HoldAnchor":
				hold_anchor = node
			"HoldAnchorLeft":
				hold_anchor_left = node
			"HoldAnchorRight":
				hold_anchor_right = node		
			"HipsAnchor":
				hips_anchor = node	
			"EyesAnchor":
				eyes_anchor = node	
	if node is GameCharacterBodyAnimationScript:
		animation_script = node

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
	
	eyes_anchor.global_position = head_anchor.to_global(eyes_anchor_offset)
	hold_anchor.global_position.y = lerpf(hips_anchor.global_position.y, head_anchor.global_position.y, hold_offset_crouch if character.is_crouching else hold_offset_stand)
	
	dev.draw_gizmo_sphere(self, "head_anchor", head_anchor.global_position, 0.2, Color.CYAN)
	dev.draw_gizmo_sphere(self, "hips_anchor", head_anchor.global_position, 0.2, Color.LIGHT_SEA_GREEN)
	dev.draw_gizmo_sphere(self, "hold_anchor", hold_anchor.global_position, 0.2, Color.AQUAMARINE)
	dev.draw_gizmo_sphere(self, "eyes_anchor", eyes_anchor.global_position, 0.1, Color.PALE_TURQUOISE)

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

func _enable_character_stand_collision():
	character.character_collider.shape = stand_collider_shape
	character.character_collider.position = stand_collider_position
	pass
	
func _enable_character_crouch_collision():
	character.character_collider.shape = crouch_collider_shape
	character.character_collider.position = crouch_collider_position
	pass
