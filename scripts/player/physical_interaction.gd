extends Node3D

class_name PlayerPhysicalInteraction
@onready var player: Player = $"../.."

@onready var ceil_test_rayset: RaySet = $CeilTestRaySet
@onready var wall_test_rayset: RaySet = $WallTestRaySet

@onready var hand_manipulation_ray: RayCast3D = $HandManipulationRay
@onready var hand_manipulation_pin_point: Node3D = $HandManipulationPinPoint

var current_hand_manipulation_target: RigidBody3D
var hand_manipulation_close_grip: bool = false

@export var hand_manipulation_pull_force: float = 1000
@export var hand_manipulation_close_grip_distance: float = 0.2
@export var hand_manipulation_throw_power: float = 32
@export var hand_manipulation_throw_ballistics: float = 0.25
@export var hand_manipulation_drop_power: float = 2
@export var hand_manipulation_max_weight: float = 50

var elevation_allowed: bool = true
var is_touching_wall: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	#ceil_check_cast.add_exception(player)
	pass # Replace with function body.

func _process(delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_check_physical_object_in_hand(delta)
	_check_wall(delta)
	_check_ceil(delta)
	
func _check_wall(delta):
	if player.is_on_wall() && wall_test_rayset.is_any_colliding():
		is_touching_wall = true
	else:
		is_touching_wall = false
		
func _check_ceil(delta):
	if ceil_test_rayset.is_any_colliding():
		elevation_allowed = false
	else:
		elevation_allowed = true
			
func _check_physical_object_in_hand(delta):
	if current_hand_manipulation_target == null:
		if Input.is_action_just_pressed("grab") and hand_manipulation_ray.is_colliding():
			var collider = hand_manipulation_ray.get_collider()
			if collider is RigidBody3D:
				collider.add_collision_exception_with(player)
				current_hand_manipulation_target = collider
				hand_manipulation_close_grip = false
				
		else:
			pass
	else:
		if Input.is_action_pressed("throw"):
			var ray_direction = tools.get_global_forward_vector(self)
			current_hand_manipulation_target.linear_velocity = (ray_direction + (Vector3.UP * hand_manipulation_throw_ballistics)).normalized() * hand_manipulation_throw_power * get_hand_manipulation_mass_penalty()
			current_hand_manipulation_target.remove_collision_exception_with(player)
			current_hand_manipulation_target = null
			
		else:
			if Input.is_action_pressed("grab"):
				current_hand_manipulation_target.linear_velocity = (hand_manipulation_pin_point.global_position - current_hand_manipulation_target.global_position) * hand_manipulation_pull_force * get_hand_manipulation_mass_penalty() * delta
#				current_hand_manipulation_target.linear_velocity = (current_hand_manipulation_target.global_position.direction_to(hand_manipulation_pin_point.global_position)) * hand_manipulation_pull_force * delta
				hand_manipulation_close_grip = current_hand_manipulation_target.global_position.distance_to(hand_manipulation_pin_point.global_position) < hand_manipulation_close_grip_distance
			else:
				current_hand_manipulation_target.remove_collision_exception_with(player)
				current_hand_manipulation_target.linear_velocity = Vector3.UP * hand_manipulation_drop_power * get_hand_manipulation_mass_penalty()
				current_hand_manipulation_target = null
				
	dev.print_screen("hand manipulation", "none" if current_hand_manipulation_target == null else current_hand_manipulation_target.name)	
	dev.print_screen("hand manipulation mass penalty", "hand manipulation mass penalty: %s" % get_hand_manipulation_mass_penalty())
	dev.print_screen("hmcg","hand manipulation cg: %s" % hand_manipulation_close_grip)

func get_hand_manipulation_mass_penalty() -> float:
	if current_hand_manipulation_target != null:
		return 1. - clampf((current_hand_manipulation_target.mass / hand_manipulation_max_weight), 0, 1)
	else:
		return 0
