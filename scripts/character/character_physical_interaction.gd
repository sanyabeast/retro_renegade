extends Node3D

class_name GameCharacterPhysicalInteractionManager

@export var camera_raycast: RayCast3D

@export_subgroup("Surface Sensors")
@export var bottom_front_cast: ShapeCast3D
@export var top_front_cast: ShapeCast3D

@export_subgroup("Ceil Cast")
@export var ceil_rayset: RaySet
@export var ceil_rayset_offset: Vector3 = Vector3.DOWN * 0.5

var held_object: RigidBody3D
var hand_manipulation_close_grip: bool = false

var elevation_allowed: bool = true
var is_touching_wall: bool = false
var is_holding_object: bool = false

var _hand_manipulation_target_dimensions: AABB = AABB(Vector3.ZERO, Vector3.ZERO)

## Automatically sets by GameCharacter class
@export var character: GameCharacter

signal on_object_grab(obj: Node3D)
signal on_object_drop(obj: Node3D)
signal on_object_throw(obj: Node3D)

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(camera_raycast != null, "camera_raycast must be explicitly set")
	pass # Replace with function body.

func _process(delta):
	_update_transforms()
	dev.draw_gizmo_cube(self, "bottom-front-sensor", bottom_front_cast.to_global(Vector3.FORWARD / 2), Vector3(0.7, 0.7, 1), character.global_basis.z, Color.ORANGE if bottom_front_cast.is_colliding() else Color.PALE_GREEN)
	
	if top_front_cast.enabled:
		dev.draw_gizmo_cube(self, "top-front-sensor", top_front_cast.to_global(Vector3.FORWARD / 2), Vector3(0.7, 0.7, 1), character.global_basis.z, Color.ORANGE if top_front_cast.is_colliding() else Color.PALE_GREEN)
	else:
		dev.hide_gizmo(self, "top-front-sensor")
	pass
	
func initialize(_character: GameCharacter):
	character = _character
	add_exception(character)
	
	character.on_crouch_entered.connect(_enable_crouch_mode)
	character.on_crouch_exited.connect(_disable_crouch_mode)
	
	ceil_rayset.position = Vector3.ZERO
	ceil_rayset.reparent(character.body_controller.head_anchor)

func add_exception(node):
	camera_raycast.add_exception(node)
	
	if top_front_cast != null:
		top_front_cast.add_exception(node)
	
	if bottom_front_cast != null:
		bottom_front_cast.add_exception(node)
		
	if ceil_rayset != null:
		ceil_rayset.add_exception(node)

func remove_exception(node):
	camera_raycast.remove_exception(node)
	
	if top_front_cast != null:
		top_front_cast.remove_exception(node)
	
	if bottom_front_cast != null:
		bottom_front_cast.remove_exception(node)
		
	if ceil_rayset != null:
		ceil_rayset.remove_exception(node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_check_physical_object_in_hand(delta)
	_check_wall(delta)
	_check_ceil(delta)

func _update_transforms():
	if character.camera_rig != null:
		var camera = character.camera_rig.get_camera()
		camera_raycast.global_position = camera.global_position
		camera_raycast.global_rotation = camera.global_rotation
		
func _check_wall(delta):
	var new_is_touching_wall: bool = false
	
	if top_front_cast != null:
		if top_front_cast.get_collision_count() > 0:
			var collider = top_front_cast.get_collider(0)
			if collider is StaticBody3D:
				var normal = top_front_cast.get_collision_normal(0)
				if normal.dot(character.global_basis.z) > 0.8:
					new_is_touching_wall = true
	
	if bottom_front_cast != null:
		if bottom_front_cast.get_collision_count() > 0:
			var collider = bottom_front_cast.get_collider(0)
			if collider is StaticBody3D:
				var normal = bottom_front_cast.get_collision_normal(0)
				if normal.dot(character.global_basis.z) > 0.8:
					new_is_touching_wall = true
	
	is_touching_wall = new_is_touching_wall
		
func _check_ceil(delta):
	var new_elevation_allowed: bool = true
	
	if ceil_rayset != null:
		ceil_rayset.global_position = character.body_controller.head_anchor.global_position + ceil_rayset_offset
		
		var obj = ceil_rayset.get_first_colliding_ray()
		if obj != null:
			print(obj)
			new_elevation_allowed = false
	
	elevation_allowed = new_elevation_allowed
			
func _check_physical_object_in_hand(delta):
	if held_object != null:
		var hold_anchor = character.body_controller.hold_anchor
		var distance: float = held_object.global_position.distance_to(character.global_position)
		
		held_object.linear_velocity = (hold_anchor.global_position - held_object.global_position) * character.props.hand_manipulation_pull_force * get_hand_manipulation_mass_penalty() * delta		
		hand_manipulation_close_grip = held_object.global_position.distance_to(hold_anchor.global_position) < character.props.hand_manipulation_close_grip_distance
		
		if distance > app.config.character_physical_interaction_grab_fail_distance + app.config.character_physical_interaction_grab_max_distance:
			dev.logd("GameCharacterPhysicalInteractionManager", "hand manipulated item is missed due to distance")
			stop_grab()
				
	dev.print_screen("hand manipulation", "hand manip. target: %s" % ("none" if held_object == null else held_object.name))	
	dev.print_screen("hand manipulation mass penalty", "hand manip. penalty: %s" % tools.progress_to_percentage(get_hand_manipulation_mass_penalty()))
	
func start_grab():
	if held_object == null and  camera_raycast.is_colliding():
		var collider = camera_raycast.get_collider()
		if collider is RigidBody3D:
			var distance = character.global_position.distance_to(collider.global_position)
			if distance < app.config.character_physical_interaction_grab_max_distance:
				var collider_mesh: MeshInstance3D = tools.find_first_node_of_type_recursively(collider, tools.ENodeType.MeshInstance)
			
				if collider_mesh != null:
					_hand_manipulation_target_dimensions = collider_mesh.mesh.get_aabb()
				
				character.add_collision_exception(collider)
				held_object = collider
				
				is_holding_object = true
				
				on_object_grab.emit(held_object)
				hand_manipulation_close_grip = false
	
func stop_grab():
	if held_object != null:
		held_object.linear_velocity = Vector3.UP * character.props.hand_manipulation_drop_power * get_hand_manipulation_mass_penalty()
		on_object_drop.emit(held_object)
		character.remove_collision_exception(held_object)
		held_object = null
		is_holding_object = false
		
func start_throw():
	if held_object != null:
		var ray_direction = tools.get_global_forward_vector(camera_raycast)
		held_object.linear_velocity = (ray_direction + (Vector3.UP * character.props.hand_manipulation_throw_ballistics)).normalized() * character.props.hand_manipulation_throw_power * get_hand_manipulation_mass_penalty()
		character.remove_collision_exception(held_object)
		on_object_throw.emit(held_object)
		held_object = null
		is_holding_object = false
		
func get_hand_manipulation_mass_penalty() -> float:
	if held_object != null:
		return 1. - clampf((held_object.mass / character.props.hand_manipulation_max_weight), 0, 1)
	else:
		return 0

func _enable_crouch_mode():
	top_front_cast.enabled = false
	
func _disable_crouch_mode():
	top_front_cast.enabled = true
