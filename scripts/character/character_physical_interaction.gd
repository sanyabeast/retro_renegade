extends Node3D

class_name GameCharacterPhysicalInteractionManager

@export var ceil_test_rayset: RaySet
@export var wall_test_rayset: RaySet
@export var camera_raycast: RayCast3D

var current_hand_manipulation_target: RigidBody3D
var hand_manipulation_close_grip: bool = false

var elevation_allowed: bool = true
var is_touching_wall: bool = false

var _hand_manipulation_target_dimensions: AABB = AABB(Vector3.ZERO, Vector3.ZERO)

## Automatically sets by GameCharacter class
@export var character: GameCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(camera_raycast != null, "camera_raycast must be explicitly set")
	assert(wall_test_rayset != null, "wall_test_rayset must be explicitly set")
	assert(ceil_test_rayset != null, "ceil_test_rayset must be explicitly set")
	
	camera_raycast.add_exception(character)
	wall_test_rayset.add_exception(character)
	ceil_test_rayset.add_exception(character)
	
	pass # Replace with function body.

func _process(delta):
	_update_transforms()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_check_physical_object_in_hand(delta)
	_check_wall(delta)
	_check_ceil(delta)

func _update_transforms():
	wall_test_rayset.global_rotation = character.global_rotation
	
	if character.camera_rig != null:
		var camera = character.camera_rig.get_camera()
		camera_raycast.global_position = camera.global_position
		camera_raycast.global_rotation = camera.global_rotation
		
	if character.body_controller and character.body_controller.head_pin_point != null:
		ceil_test_rayset.global_position = character.body_controller.head_pin_point.global_position
		 
	if character.body_controller and character.body_controller.chest_pin_point != null:	
		wall_test_rayset.global_position = character.body_controller.chest_pin_point.global_position
		
func _check_wall(delta):
	if character.is_on_wall() && wall_test_rayset.is_any_colliding():
		is_touching_wall = true
	else:
		is_touching_wall = false
		
func _check_ceil(delta):
	if ceil_test_rayset.is_any_colliding():
		elevation_allowed = false
	else:
		elevation_allowed = true
			
func _check_physical_object_in_hand(delta):
	if character != null and character.get_hand_pin_point() != null:
		if current_hand_manipulation_target != null:
			var distance: float = current_hand_manipulation_target.global_position.distance_to(character.global_position)
			
			current_hand_manipulation_target.linear_velocity = (character.get_hand_pin_point().global_position - current_hand_manipulation_target.global_position) * character.props.hand_manipulation_pull_force * get_hand_manipulation_mass_penalty() * delta		
			hand_manipulation_close_grip = current_hand_manipulation_target.global_position.distance_to(character.get_hand_pin_point().global_position) < character.props.hand_manipulation_close_grip_distance
			
			if distance > app.config.character_physical_interaction_grab_fail_distance + app.config.character_physical_interaction_grab_max_distance:
				dev.logd("GameCharacterPhysicalInteractionManager", "hand manipulated item is missed due to distance")
				stop_grab()
				
	dev.print_screen("hand manipulation", "hand manip. target: %s" % ("none" if current_hand_manipulation_target == null else current_hand_manipulation_target.name))	
	dev.print_screen("hand manipulation mass penalty", "hand manip. penalty: %s" % tools.progress_to_percentage(get_hand_manipulation_mass_penalty()))
	
func start_grab():
	if current_hand_manipulation_target == null and  camera_raycast.is_colliding():
		var collider = camera_raycast.get_collider()
		print(collider)
		if collider is RigidBody3D:
			var distance = character.global_position.distance_to(collider.global_position)
			if distance < app.config.character_physical_interaction_grab_max_distance:
				var collider_mesh: MeshInstance3D = tools.find_first_node_of_type_recursively(collider, tools.ENodeType.MeshInstance)
				print(collider_mesh)
				
				
				if collider_mesh != null:
					_hand_manipulation_target_dimensions = collider_mesh.mesh.get_aabb()
				
				character.body_controller.add_collision_exception_for_body_physics(collider)
				current_hand_manipulation_target = collider
				hand_manipulation_close_grip = false
	
func stop_grab():
	if current_hand_manipulation_target != null:
		character.body_controller.remove_collision_exception_for_body_physics(current_hand_manipulation_target)
		current_hand_manipulation_target.linear_velocity = Vector3.UP * character.props.hand_manipulation_drop_power * get_hand_manipulation_mass_penalty()
		current_hand_manipulation_target = null
		
func start_throw():
	if current_hand_manipulation_target != null:
		var ray_direction = tools.get_global_forward_vector(camera_raycast)
		current_hand_manipulation_target.linear_velocity = (ray_direction + (Vector3.UP * character.props.hand_manipulation_throw_ballistics)).normalized() * character.props.hand_manipulation_throw_power * get_hand_manipulation_mass_penalty()
		current_hand_manipulation_target.remove_collision_exception_with(character)
		current_hand_manipulation_target = null
		
func get_hand_manipulation_mass_penalty() -> float:
	if current_hand_manipulation_target != null:
		return 1. - clampf((current_hand_manipulation_target.mass / character.props.hand_manipulation_max_weight), 0, 1)
	else:
		return 0
