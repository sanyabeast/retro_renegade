extends CharacterBody3D


const SPEED = 0.4
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()
var current_target_point: Vector3 = Vector3.ZERO
var is_idle: bool = true

var _direction: Vector3 = Vector3.ZERO
var _walk_direction: Vector3 = Vector3.ZERO
var _look_direction: Vector3 = Vector3.ZERO

var _animation_tree: AnimationTree
var _animation_player: AnimationPlayer

var _current_move_speed: float = 0
var _target_move_speed: float = 0

func _ready():
	_traverse(self)
	print(_animation_tree)
	_switch_target_point()

func _process(delta):
	
	if _timer_gate.check("toggle_target_point", 5) and tools.random_bool2(0.5):
		_switch_target_point()
		
	if _timer_gate.check("toggle_idle", 3):
		is_idle = tools.random_bool2(0.25)
	
	_direction = Vector3.ZERO if is_idle else ((global_position - current_target_point).normalized())
	_target_move_speed = 0 if is_idle else SPEED
	_current_move_speed = move_toward(_current_move_speed, _target_move_speed, 1 * delta)
	_walk_direction = _walk_direction.move_toward(_direction, 0.5 * delta)
	_look_direction = _look_direction.move_toward(_direction, 0.5 * delta)
	
	look_at(global_position + _look_direction)
		
	print(_direction)
	
	_update_animation_params()
		

func _traverse(node):
	# Call the callback function on the current node
	
	if node is AnimationPlayer:
		_animation_player = node
		
	if node is AnimationTree:
		_animation_tree = node
		_animation_tree.active = true
		
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)

func _switch_target_point():
	current_target_point = global_position +  Vector3(
		randf_range(-16, 16),
		0,
		randf_range(-16, 16),
	)

		
func _update_animation_params():
		if velocity.length() < 0.01:
			_animation_tree["parameters/conditions/idle"] = true
			_animation_tree["parameters/conditions/is_walking"] = false
			
		if velocity.length() >= 0.01:
			_animation_tree["parameters/conditions/idle"] = false
			_animation_tree["parameters/conditions/is_walking"] = true	
			
		_animation_tree["parameters/Idle/blend_position"] = lerpf(-1, 1, clampf(velocity.length() / SPEED, 0, 1))
		_animation_tree["parameters/Walk/blend_position"] = lerpf(-1, 1, clampf(velocity.length() / SPEED, 0, 1))
	
		_animation_player.speed_scale = 1 if is_idle else (velocity.length() / SPEED)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	velocity.x = _walk_direction.x * _current_move_speed
	velocity.z = _walk_direction.z * _current_move_speed

	move_and_slide()
	
