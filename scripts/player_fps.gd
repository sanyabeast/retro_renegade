extends CharacterBody3D
class_name Player

const MOUSE_SENSITIVITY = 0.1
const GRAVITY: float = -32

@export var props: RPlayerProperties

@onready var camera: FPSCameraManager = $CameraRoot/CameraManager
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var torch: SpotLight3D = $CameraRoot/Torch
@export var phys_interaction: PlayerPhysicalInteraction

var dir = Vector3.ZERO

var current_climbing_power: float = 0
var current_jetpack_power: float = 0
var current_sprint_power: float = 0
var current_jump_power: float = 0
var current_dash_power: float = 0

var is_climbing: bool = false
var is_sprinting: bool = false
var is_jumping: bool = false
var is_crouching: bool = false

var travelled: float = 0
var _prev_global_position: Vector3 = Vector3.ZERO

var current_movement_responsivness: float = 1
var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()

func _ready():
	add_to_group("players")
	print("PlayerFPS: ready")
	_prev_global_position = global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta):
	
	travelled += (global_position - _prev_global_position).length()
	_prev_global_position = global_position
	
	dev.print_screen("player_pos", "player pos: %s" % global_position)
	dev.print_screen("player_vel", "player vel: %s" % velocity.length())
	dev.print_screen("player_climb", "player climb power: %s" % current_climbing_power)
	dev.print_screen("player_crouch", "player crouching: %s" % is_crouching)
	dev.print_screen("player_travelled", "player travelled: %s" % travelled)
	
	current_climbing_power = move_toward(current_climbing_power, 0, (1/props.climbing_timeout) * delta)
	
func _physics_process(delta):
	if current_jump_power == 1:
		current_jump_power = 0
		
	current_dash_power = move_toward(current_dash_power, 0, (1 / props.dash_duration) * delta)
	
	process_user_input()
	process_movement(delta)
	
	pass

func process_movement(delta):
	var _walk_speed = props.walk_speed
	var _jump_speed = props.jump_speed
	
	if is_crouching:
		_walk_speed = _walk_speed * props.crouching_walk_penalty
		_jump_speed = _jump_speed * props.crouching_jump_penalty
	else:
		_walk_speed = lerpf(props.walk_speed, props.sprint_speed, current_sprint_power) 
	
	var target_vel = dir * _walk_speed
	
	velocity.y += GRAVITY * delta
	velocity.y += current_jetpack_power * (props.jetpack_speed) * delta
	velocity.y += current_climbing_power * (props.climbing_speed) * delta
	velocity.y += current_jump_power * (_jump_speed)
	
	velocity.y = clampf(velocity.y, props.vertical_velocity_min, props.vertical_velocity_max)
	
	velocity.x = target_vel.x
	velocity.z = target_vel.z
	
	velocity += tools.get_forward_vector(self) * props.dash_speed * current_dash_power
	
	
	
	move_and_slide()

# INPUT
func process_user_input():
	dir = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		dir -= global_transform.basis.z
	if Input.is_action_pressed("backward"):
		dir += global_transform.basis.z
	if Input.is_action_pressed("right"):
		dir += global_transform.basis.x
	if Input.is_action_pressed("left"):
		dir -= global_transform.basis.x
		
	#print("is on wall: %s" % phys_interaction.is_touching_wall)	
	#print("is on floor: %s" % is_on_floor())	
		
	
	if props.allow_jetpack:
		if Input.is_action_pressed('jump'):
			current_jetpack_power = 1;
		else:
			current_jetpack_power = 0
			
	if props.allow_climbing:
		if not is_climbing:
			if phys_interaction.is_touching_wall and Input.is_action_pressed('jump'):
				is_climbing = true
				current_climbing_power = 1
				dir *= 0.1
		if is_climbing:
			if not phys_interaction.is_touching_wall or not Input.is_action_pressed('jump'):
				is_climbing = false;
				current_climbing_power = 0
			else:
				dir *= 0.1
				
#		if phys_interaction.is_touching_wall and Input.is_action_pressed('jump'):
#			current_climbing_power = 1;
#		else:
#			current_climbing_power = move_toward(current_jump_power, 0, (1/climbing_timeout))
			
	if props.allow_jump:
		if is_on_floor() && Input.is_action_pressed('jump') and _timer_gate.check("jump", 0.25):
			print('jump')
			current_jump_power = 1;
		
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
			
	
	if Input.is_action_pressed("crouch") and not is_crouching:
		is_crouching = true
		anim_player.play("CrouchEnter")
		
		if props.allow_dash and is_sprinting:
			current_dash_power = 1
		
	if not Input.is_action_pressed("crouch") and is_crouching and phys_interaction.elevation_allowed:
		is_crouching = false
		current_dash_power = 0
		anim_player.play("CrouchExit")
		
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

