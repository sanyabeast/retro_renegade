extends CharacterBody3D
class_name Player

const MOUSE_SENSITIVITY = 0.1
const MOVEMENT_DEADZONE = 0.1
const GRAVITY: float = -32

@export var props: RPlayerProperties

@onready var camera: FPSCameraManager = $CameraRoot/CameraManager
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var torch: SpotLight3D = $CameraRoot/Torch
@export var phys_interaction: PlayerPhysicalInteraction

var current_climbing_power: float = 0
var current_sprint_power: float = 0
var current_jump_power: float = 0
var current_dash_power: float = 0

var is_climbing: bool = false
var is_sprinting: bool = false
var is_jumping: bool = false
var is_crouching: bool = false

var current_movement_direction = Vector3.ZERO
var current_movement_speed: float = 0
var target_movement_speed: float = 0
var current_movement_acceleration: float = 0

var climbing_start_distance: float = 0

var travelled: float = 0
var _prev_global_position: Vector3 = Vector3.ZERO

var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()

func _ready():
	add_to_group("players")
	print("PlayerFPS: ready")
	_prev_global_position = global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta):
	
	travelled += (global_position - _prev_global_position).length()
	_prev_global_position = global_position

	dev.print_screen("player_pos", "player xyz: %s" % global_position)
	dev.print_screen("player_vel", "player velocity: %.2f m/s" % velocity.length())
	dev.print_screen("player_crouch", "player crouching: %s" % is_crouching)
	dev.print_screen("player_travelled", "player travelled: %.2f m" % travelled)
	dev.print_screen("player_travelled_climb", "player travelled climbing: %.2f m" % ((travelled - climbing_start_distance) if is_climbing else 0))
	
func _physics_process(delta):
	if current_jump_power == 1:
		current_jump_power = 0
		
	current_dash_power = move_toward(current_dash_power, 0, (1 / props.dash_duration) * delta)
	
	process_user_input()
	process_movement(delta)
	
	pass

func process_movement(delta):
	current_movement_acceleration = 0
	if is_on_floor():	
		current_movement_acceleration = lerpf(props.walk_acceleration, props.sprint_acceleration, current_sprint_power)
	
	current_movement_speed = move_toward(current_movement_speed, target_movement_speed, current_movement_acceleration * delta)
	var min_movement_speed = props.walk_speed_min
	
	if target_movement_speed == 0:
		current_movement_speed = 0
		min_movement_speed = 0
	
	current_movement_speed = clampf(current_movement_speed, min_movement_speed , props.sprint_speed_max)
	
	var jump_speed = props.jump_speed
	var movement_penalty: float = 1
	
	if is_crouching:
		movement_penalty = props.crouching_walk_penalty
		jump_speed = jump_speed * props.crouching_jump_penalty
	
	var target_vel = current_movement_direction * current_movement_speed * movement_penalty
	
	velocity.y += lerpf(GRAVITY, 0, current_climbing_power) * delta
	#velocity.y += current_jetpack_power * (props.jetpack_speed) * delta
	velocity.y += current_climbing_power * (props.climbing_speed) * delta
	velocity.y += current_jump_power * (jump_speed)
	
	velocity.y = clampf(velocity.y, props.vertical_velocity_min, props.vertical_velocity_max)
	
	velocity.x = target_vel.x
	velocity.z = target_vel.z
	
	velocity += tools.get_forward_vector(self) * props.dash_speed * current_dash_power
	
	move_and_slide()
	
	if current_climbing_power > 0 and travelled - climbing_start_distance >= props.climbing_max_distance:
		current_climbing_power = 0

# INPUT
func process_user_input():
	# CLIMBING		
	if props.allow_climbing:
		if not is_climbing and Input.is_action_pressed('jump') and phys_interaction.is_touching_wall:
			is_climbing = true
			climbing_start_distance = travelled
			current_climbing_power = 1
			velocity.y = max(0, velocity.y)
				
		if is_on_floor() or not is_on_wall():
			is_climbing = false;
			current_climbing_power = 0
			
	# JUMPING		
	if props.allow_jump:
		if is_on_floor() && Input.is_action_pressed('jump') and _timer_gate.check("jump", 0.25):
			print('jump')
			current_jump_power = 1;
		
	# SPRINGING	
	if props.allow_sprint:
		if props.flip_sprint_walk:
			if Input.is_action_pressed("sprint"):
				current_sprint_power = 0
				is_sprinting = false
			else:
				current_sprint_power = 1
				is_sprinting = true
		else:
			if Input.is_action_pressed("sprint"):
				current_sprint_power = 1
				is_sprinting = true
			else:
				current_sprint_power = 0
				is_sprinting = false
			
	# CROUCHING
	if Input.is_action_pressed("crouch") and not is_crouching:
		is_crouching = true
		anim_player.play("CrouchEnter")
		
		if props.allow_dash and is_sprinting:
			current_dash_power = 1
		
	if not Input.is_action_pressed("crouch") and is_crouching and phys_interaction.elevation_allowed:
		is_crouching = false
		current_dash_power = 0
		anim_player.play("CrouchExit")
		
	
	# MOVEMENT DIRECTION AND TARGET SPEEDS
	current_movement_direction = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		current_movement_direction -= global_transform.basis.z
	if Input.is_action_pressed("backward"):
		current_movement_direction += global_transform.basis.z
	if Input.is_action_pressed("right"):
		current_movement_direction += global_transform.basis.x
	if Input.is_action_pressed("left"):
		current_movement_direction -= global_transform.basis.x
	
	if current_movement_direction.length() > MOVEMENT_DEADZONE:
		current_movement_direction = current_movement_direction.normalized()
		target_movement_speed = lerpf(props.walk_speed_max, props.sprint_speed_max, current_sprint_power)
	else:
		target_movement_speed = 0
	
	# EXTRAS 
	if Input.is_action_just_pressed("ui_cancel"):
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	if Input.is_action_just_pressed("torch"):
		torch.visible = !torch.visible

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# rotates the view vertically
		$CameraRoot.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		$CameraRoot.rotation_degrees.x = clamp($CameraRoot.rotation_degrees.x, -75, 75)
		# rotates the view horizontally
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

