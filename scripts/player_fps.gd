extends CharacterBody3D
class_name Player

const MOUSE_SENSITIVITY = 0.1
const GRAVITY: float = -32

@onready var camera = $CameraRoot/Camera3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
var dir = Vector3.ZERO

@export var allow_climbing: bool = true
@export var allow_jetpack: bool = false
@export var allow_sprint: bool = true
@export var allow_jump: bool = true

@export var walk_speed: float = 4
@export var climbing_speed: float = 28
@export var sprint_speed: float = 8
@export var jetpack_speed: float = 64
@export var jump_speed: float = 12

@export var climbing_timeout: float = 2

@export var crouching_walk_penalty: float = 0.5

var current_climbing_power: float = 0
var current_jetpack_power: float = 0
var current_sprint_power: float = 0
var current_jump_power: float = 0

var is_climbing: bool = false
var is_sprinting: bool = false
var is_jumping: bool = false
var is_crouching: bool = false

var current_movement_responsivness: float = 1

func _ready():
	print("PlayerFPS: ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta):
	
	
	dev.print_screen("player_pos", "player pos: %s" % global_position)
	dev.print_screen("player_vel", "player vel: %s" % velocity.length())
	dev.print_screen("player_climb", "player climb power: %s" % current_climbing_power)
	dev.print_screen("player_crouch", "player crouching: %s" % is_crouching)
	
	
	current_climbing_power = move_toward(current_climbing_power, 0, (1/climbing_timeout) * delta)
	
		
func _physics_process(delta):
	process_user_input()
	process_movement(delta)
	pass

func process_movement(delta):
	var _walk_speed = walk_speed
	
	if is_crouching:
		_walk_speed = _walk_speed * crouching_walk_penalty
	else:
		_walk_speed = lerpf(walk_speed, sprint_speed, current_sprint_power) 
	
	var target_vel = dir * _walk_speed
	
	velocity.y += GRAVITY * delta
	velocity.y += current_jetpack_power * (jetpack_speed) * delta
	velocity.y += current_climbing_power * (climbing_speed) * delta
	velocity.y += current_jump_power * (jump_speed)
	
	velocity.x = target_vel.x
	velocity.z = target_vel.z
	move_and_slide()

# INPUT
func process_user_input():
	dir = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		dir -= camera.global_transform.basis.z
	if Input.is_action_pressed("backward"):
		dir += camera.global_transform.basis.z
	if Input.is_action_pressed("right"):
		dir += camera.global_transform.basis.x
	if Input.is_action_pressed("left"):
		dir -= camera.global_transform.basis.x
		
	#print("is on wall: %s" % is_on_wall())	
	#print("is on floor: %s" % is_on_floor())	
		
	
	if allow_jetpack:
		if Input.is_action_pressed('jump'):
			current_jetpack_power = 1;
		else:
			current_jetpack_power = 0
			
	if allow_climbing:
		if not is_climbing:
			if is_on_wall() and Input.is_action_pressed('jump'):
				is_climbing = true
				current_climbing_power = 1
				dir *= 0.1
		if is_climbing:
			if not is_on_wall() or not Input.is_action_pressed('jump'):
				is_climbing = false;
				current_climbing_power = 0
			else:
				dir *= 0.1
				
#		if is_on_wall() and Input.is_action_pressed('jump'):
#			current_climbing_power = 1;
#		else:
#			current_climbing_power = move_toward(current_jump_power, 0, (1/climbing_timeout))
			
	if allow_jump:
		if is_on_floor() and Input.is_action_pressed('jump'):
			print('jump')
			current_jump_power = 1;
		else:
			current_jump_power = 0
		
	if allow_sprint:
		if Input.is_action_pressed("sprint"):
			current_sprint_power = 1
		else:
			current_sprint_power = 0
			
	
	if Input.is_action_just_pressed("crouch"):
		if not is_crouching:
			is_crouching = true
			anim_player.play("CrouchEnter")
	if Input.is_action_just_released("crouch"):
		if is_crouching:
			is_crouching = false
			anim_player.play("CrouchExit")
		
	if Input.is_action_just_pressed("ui_cancel"):
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	

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

