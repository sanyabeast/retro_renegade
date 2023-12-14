extends CollisionShape3D

class_name GameCharacterBody

@export var head_pin_point: Node3D
@export var hand_pin_point: Node3D

var character: GameCharacter
var _animation_tree: AnimationTree
var _animation_player: AnimationPlayer
var _skeleton: Skeleton3D

var is_idle: bool = true
var _smoothed_move_velocity: float = 0
var _real_move_velocity: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_tree(self)
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
	pass

func _update_animation_params(delta):
	is_idle = character.velocity.length() < 0.01
	_real_move_velocity = character.velocity.length()
	_smoothed_move_velocity = move_toward(_smoothed_move_velocity, _real_move_velocity, 0.25 * delta)
	
	if is_idle:
		_animation_tree["parameters/conditions/idle"] = true
		_animation_tree["parameters/conditions/is_walking"] = false
		
	if not is_idle:
		_animation_tree["parameters/conditions/idle"] = false
		_animation_tree["parameters/conditions/is_walking"] = true	
		
	_animation_tree["parameters/Idle/blend_position"] = lerpf(-1, 1, pow(clampf(_smoothed_move_velocity / character.props.walk_speed_max, 0, 1), 2))
	_animation_tree["parameters/Walk/blend_position"] = lerpf(-1, 1, pow(clampf(_smoothed_move_velocity / character.props.walk_speed_max, 0, 1), 2))

	_animation_player.speed_scale = 1 if is_idle else (_smoothed_move_velocity / character.props.walk_speed_max)

