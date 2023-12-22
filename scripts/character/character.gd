extends CharacterBody3D
class_name GameCharacter

const MOVEMENT_DEADZONE = 0.1

var gravity: float = -1 * ProjectSettings.get_setting("physics/3d/default_gravity")

@export var props: RCharacterProperties
@export var torch: SpotLight3D
@export var camera_rig: GameCharacterCameraRig
@export var phys_interaction: GameCharacterPhysicalInteractionManager
@export var body_controller: GameCharacterBodyController
@export var sfx_controller: CharacterSFX
@export var nav_agent: NavigationAgent3D

var current_climbing_power: float = 0
var current_sprint_power: float = 0
var current_jump_power: float = 0

var is_climbing: bool = false
var is_sprinting: bool = false
var is_jumping: bool = false
var is_crouching: bool = false

var current_movement_direction = Vector3.ZERO
var current_movement_speed: float = 0
var target_movement_speed: float = 0
var current_movement_acceleration: float = 0

var climbing_start_distance: float = 0
var jump_started: bool = false

var travelled: float = 0
var ground_travelled: float = 0
var air_travelled: float = 0

var ground_time: float = 0
var air_time: float = 0

var current_jump_charge: float = 0

var _prev_global_position: Vector3 = Vector3.ZERO
var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()

var current_vertical_velocity: float = 0
var current_horizontal_velocity: float = 0
var current_total_velocity: float = 0

var body_physics_enabled: bool = false

var body_direction: Vector3 = Vector3.FORWARD

var move_to_body_direction_factor: Vector3 = Vector3.ZERO

func _ready():
	dev.logd("PlayerFPS", "ready")
	_setup_tree(self)
	
	if body_controller != null:
		body_controller.character = self
		body_controller.initialize()
		camera_rig.body_controller = body_controller
		
	_prev_global_position = global_position
	world.link_character(self)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if camera_rig != null:
		dev.logd("GameCharacater %s" % name, "linking player to camera_rig")
		camera_rig.character = self
		
	if sfx_controller != null:
		dev.logd("GameCharacater %s" % name, "linking player to sfx_controller")
		sfx_controller.character = self	
	
	if phys_interaction != null:
		dev.logd("GameCharacater %s" % name, "linking player to phys_interaction")
		phys_interaction.character = self	

	if nav_agent == null:
		nav_agent = NavigationAgent3D.new()
		dev.logd("GameCharacater %s" % name, "creating NavigationAgent3D for character")
		add_child(nav_agent)
	

func _setup_tree(node):
	# Call the callback function on the current node
	
	if camera_rig == null and node is GameCharacterCameraRig:
		camera_rig = node
		
	if phys_interaction == null and node is GameCharacterPhysicalInteractionManager:
		phys_interaction = node
		
	if body_controller == null and node is GameCharacterBodyController:
		body_controller = node
		
	if sfx_controller == null and node is CharacterSFX:
		sfx_controller = node	
	
	if nav_agent == null and node is NavigationAgent3D:
		nav_agent = node	
		
	if node is GameCharacterBodyController:
		node.character = self	
		node.add_collision_exception_for_body_physics(self)
	
	# Recursively call this function on all children
	for child in node.get_children():
		_setup_tree(child)

func _exit_tree():
	world.unlink_character(self)

func _process(delta):

	travelled += (global_position - _prev_global_position).length()
	
	# SFX CONTROLLER CACTIONS COMMITTING
	# LANDING TRACKING
	
	# Direction Factor:
	
	dev.print_screen("char_move_dir_factor", "Player move direction factor: %s" % move_to_body_direction_factor)
	
	if not is_touching_floor():
		ground_travelled = 0
		ground_time = 0
		
		air_travelled += (global_position - _prev_global_position).length()
		air_time += delta
	else:
		ground_travelled += (global_position - _prev_global_position).length()
		ground_time += delta
		
		if air_travelled > 0:
			var landing_impact: float = clamp(abs(current_vertical_velocity) / 16, 0, 1)
			
			sfx_controller.commit_action(CharacterSFX.EActionType.Landing, landing_impact)
			if body_controller != null:
				body_controller.commit_landing(pow(landing_impact, 2))
			
			air_travelled = 0
			air_time = 0
	
	# WALKING / SPRINTING / STAYING
	if is_touching_floor():
		 
		sfx_controller.commit_action(
			CharacterSFX.EActionType.Walk, 
			clampf(Vector2(velocity.x, velocity.z).length() / get_walk_speed_max(), 0, 1)
		)
	else:
		sfx_controller.commit_action(CharacterSFX.EActionType.Walk, 0)
	
	if is_sprinting:
		sfx_controller.commit_action(
			CharacterSFX.EActionType.Sprint, 
			_get_walk_to_sprint_progress()
		)
	else:
		sfx_controller.commit_action(CharacterSFX.EActionType.Sprint, 0	)

	if jump_started and is_touching_floor():
		current_jump_charge += delta
		if current_jump_charge > props.jump_max_charge_duration:
			finish_jump()
	else:
		current_jump_charge = 0

	_prev_global_position = global_position
	
	current_vertical_velocity = velocity.y
	current_horizontal_velocity = Vector2(velocity.x, velocity.z).length()
	current_total_velocity = velocity.length()
	
func _physics_process(delta):
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z).normalized()
	
	if horizontal_velocity.length() > 0.05:
		move_to_body_direction_factor = Vector3(
			horizontal_velocity.dot(global_transform.basis.x.normalized()),
			clampf(velocity.y, -1, 1),
			-horizontal_velocity.dot(global_transform.basis.z.normalized())
		)
	else:
		move_to_body_direction_factor = Vector3(0, clampf(velocity.y, -1, 1), 0)
	
	
	if is_touching_floor() or not is_touching_wall():
		stop_climb()

	#process_user_input()
	if not body_physics_enabled:
		process_movement(delta)
	else:
		pass
		var anchor_transform: Transform3D = body_controller.get_physics_body_anchor_transform()
		global_position = anchor_transform.origin
		
	if current_jump_power > 0:
		current_jump_power = 0

	pass

func process_movement(delta):
	current_movement_acceleration = 0
	if is_on_floor():
		current_movement_acceleration = lerpf(props.walk_acceleration, props.sprint_acceleration, current_sprint_power)

	current_movement_speed = move_toward(current_movement_speed, target_movement_speed, current_movement_acceleration * delta)
	var min_movement_speed = get_walk_speed_min()

	if target_movement_speed == 0:
		current_movement_speed = 0
		min_movement_speed = 0

	current_movement_speed = clampf(current_movement_speed, min_movement_speed , get_sprint_speed_max())

	var jump_speed = props.jump_speed
	var movement_penalty: float = 1

	if is_crouching:
		movement_penalty = props.crouching_walk_penalty
		jump_speed = jump_speed * props.crouching_jump_penalty

	var target_vel = current_movement_direction * current_movement_speed * movement_penalty

	velocity.y += lerpf(gravity * props.gravity_multiplier, 0, current_climbing_power) * delta
	velocity.y += current_climbing_power * (props.climbing_speed) * delta
	velocity.y += current_jump_power * (jump_speed)
	
	velocity.y = clampf(velocity.y, props.vertical_velocity_min, props.vertical_velocity_max)

	velocity.x = target_vel.x
	velocity.z = target_vel.z


	move_and_slide()

	if current_climbing_power > 0 and travelled - climbing_start_distance >= props.climbing_max_distance:
		current_climbing_power = 0

func set_movement_direction(movement_direction: Vector3):
	current_movement_direction = movement_direction
	
	if current_movement_direction.length() > MOVEMENT_DEADZONE:
		current_movement_direction = current_movement_direction.normalized()
		target_movement_speed = lerpf(get_walk_speed_max(), get_sprint_speed_max(), current_sprint_power)
		
	else:
		target_movement_speed = 0
	pass
	
func set_body_direction(direction: Vector3):
	body_direction = Vector3(direction.x, 0, direction.z)
	if body_direction.length() > 0.01:
		look_at(global_position + body_direction.normalized())

func set_body_direction_target(target: Vector3):
	set_body_direction(target - global_position)

func look_at_direction(look_direction: Vector3):
	pass
	#look_at(global_position + Vector3(look_direction.x, 0, look_direction.y))

func set_torch_visible(visible: bool):
	if torch != null:
		torch.visible = visible

func is_torch_visible()->bool:
	if torch != null:
		return torch.visible
	else:
		return false

func start_climb():
	if not is_climbing and is_touching_wall():
		is_climbing = true
		climbing_start_distance = travelled
		current_climbing_power = 1
		velocity.y = max(0, velocity.y)
		
		if sfx_controller != null:
			sfx_controller.commit_action(CharacterSFX.EActionType.ClimbStart)

func stop_climb():
	is_climbing = false;
	current_climbing_power = 0

func start_jump():
	if not jump_started and is_touching_floor():
		current_jump_charge = 0
		jump_started = true
		
func cancel_jump():
	if jump_started:
		jump_started = false
		current_jump_charge = 0

func finish_jump():
	if jump_started and is_touching_floor():
		current_jump_power = sqrt(clampf(current_jump_charge / props.jump_max_charge_duration, 0, 1));
		jump_started = false
		current_jump_charge = 0
		
		if sfx_controller != null and is_on_floor_only():
			sfx_controller.commit_action(CharacterSFX.EActionType.JumpStart)
# SPRINTING
func start_sprint():
	current_sprint_power = 1
	is_sprinting = true
	
func stop_sprint():
	current_sprint_power = 0
	is_sprinting = false

# CROUCHING
func start_crouch():
	if not is_crouching:
		is_crouching = true
	
func stop_crouch():
	if is_crouching and is_elevation_allowed():
		is_crouching = false

# PHYSICAL INTERACTION
func is_touching_wall()->bool:
	if phys_interaction != null:
		return phys_interaction.is_touching_wall
	else:
		return is_on_wall()

func is_touching_floor()->bool:
	return is_on_floor()


func is_elevation_allowed():
	if phys_interaction != null:
		return phys_interaction.elevation_allowed
	else:
		return not is_on_ceiling()

# GRAB / DROP / THROW
func start_grab():
	if phys_interaction != null:
		phys_interaction.start_grab()

func stop_grab():
	if phys_interaction != null:
		phys_interaction.stop_grab()
		
func start_throw():
	if phys_interaction != null:
		phys_interaction.start_throw()	

# CAMERA
func process_camera_input(event):
	if camera_rig != null:
		camera_rig.process_camera_input(event)

func get_camera():
	if camera_rig != null:
		return camera_rig.get_camera()
	else: 
		return null

func start_body_physics():
	if body_controller != null and not body_physics_enabled:
		body_physics_enabled = true  
		body_controller.start_body_physics()
	pass

func stop_body_physics():
	if body_controller != null and body_physics_enabled:
		body_physics_enabled = false  
		var anchor_transform: Transform3D = body_controller.get_physics_body_anchor_transform()
		global_position = anchor_transform.origin
		body_controller.stop_body_physics()
	pass

func set_camera_mode(new_mode: GameCharacterCameraRig.EGameCharacterCameraMode):
	if camera_rig != null:
		camera_rig.set_camera_mode(new_mode)
		
func next_camera_mode():
	if camera_rig != null:
		camera_rig.next_camera_mode()

func get_hand_pin_point():
	if body_controller != null:
		return body_controller.hand_pin_point

func get_sprint_speed_max()->float:
	print(props.sprint_speed_max if move_to_body_direction_factor.z >= -0.1 else props.back_sprint_speed_max)
	return props.sprint_speed_max if move_to_body_direction_factor.z >= -0.1 else props.back_sprint_speed_max

func get_walk_speed_max()->float:
	return props.walk_speed_max if move_to_body_direction_factor.z >= -0.1 else props.back_walk_speed_max

func get_walk_speed_min()->float:
	return props.walk_speed_min if move_to_body_direction_factor.z >= -0.1 else props.back_walk_speed_min

func _get_walk_to_sprint_progress()->float:
	return clampf((Vector2(velocity.x, velocity.z).length() - get_walk_speed_max()) / (get_sprint_speed_max() - get_walk_speed_max()), 0, 1)
