extends Node3D

class_name GameCharacterPhysicalInteractionManager
@export var player: GameCharacter

@export var ceil_test_rayset: RaySet
@export var wall_test_rayset: RaySet

@export var hand_manipulation_ray: RayCast3D
@export var hand_manipulation_pin_point: Node3D

var current_hand_manipulation_target: RigidBody3D
var hand_manipulation_close_grip: bool = false

var elevation_allowed: bool = true
var is_touching_wall: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#ceil_check_cast.add_exception(player)
	pass # Replace with function body.

func _process(delta):
	dev.print_screen("player_phys_touch_wall", "player touches wall: %s" % is_touching_wall)
	dev.print_screen("player_phys_touch_wall", "player landed: %s" % player.is_on_floor())
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
	if current_hand_manipulation_target != null:
		current_hand_manipulation_target.linear_velocity = (hand_manipulation_pin_point.global_position - current_hand_manipulation_target.global_position) * player.props.hand_manipulation_pull_force * get_hand_manipulation_mass_penalty() * delta		
		hand_manipulation_close_grip = current_hand_manipulation_target.global_position.distance_to(hand_manipulation_pin_point.global_position) < player.props.hand_manipulation_close_grip_distance
				
	dev.print_screen("hand manipulation", "hand manip. target: %s" % ("none" if current_hand_manipulation_target == null else current_hand_manipulation_target.name))	
	dev.print_screen("hand manipulation mass penalty", "hand manip. penalty: %s" % tools.progress_to_percentage(get_hand_manipulation_mass_penalty()))
	
func start_grab():
	if current_hand_manipulation_target == null and  hand_manipulation_ray.is_colliding():
		var collider = hand_manipulation_ray.get_collider()
		if collider is RigidBody3D:
			collider.add_collision_exception_with(player)
			current_hand_manipulation_target = collider
			hand_manipulation_close_grip = false
	
func stop_grab():
	if current_hand_manipulation_target != null:
		current_hand_manipulation_target.remove_collision_exception_with(player)
		current_hand_manipulation_target.linear_velocity = Vector3.UP * player.props.hand_manipulation_drop_power * get_hand_manipulation_mass_penalty()
		current_hand_manipulation_target = null
		
func start_throw():
	if current_hand_manipulation_target != null:
		var ray_direction = tools.get_global_forward_vector(hand_manipulation_ray)
		current_hand_manipulation_target.linear_velocity = (ray_direction + (Vector3.UP * player.props.hand_manipulation_throw_ballistics)).normalized() * player.props.hand_manipulation_throw_power * get_hand_manipulation_mass_penalty()
		current_hand_manipulation_target.remove_collision_exception_with(player)
		current_hand_manipulation_target = null
		
func get_hand_manipulation_mass_penalty() -> float:
	if current_hand_manipulation_target != null:
		return 1. - clampf((current_hand_manipulation_target.mass / player.props.hand_manipulation_max_weight), 0, 1)
	else:
		return 0
