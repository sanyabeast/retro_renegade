extends Node3D

class_name GameCharacterPhysicalInteractionManager

# RayCast3D for camera raycasting
@export var camera_raycast: RayCast3D

# Surface sensors for detecting collisions
@export_subgroup("Surface Sensors")
@export var bottom_front_cast: ShapeCast3D
@export var top_front_cast: ShapeCast3D

# RaySet for ceiling detection
@export_subgroup("Ceil Cast")
@export var ceil_rayset: RaySet
@export var ceil_rayset_offset: Vector3 = Vector3.DOWN * 0.5

# Currently held object and manipulation flags
var held_object: RigidBody3D
var hand_manipulation_close_grip: bool = false

# Flags for character state
var elevation_allowed: bool = true
var is_touching_wall: bool = false
var is_holding_object: bool = false

# Dimensions of the target object for hand manipulation
var _hand_manipulation_target_dimensions: AABB = AABB(Vector3.ZERO, Vector3.ZERO)

## Automatically set by the GameCharacter class
@export var character: GameCharacter

# Signals emitted when an object is grabbed, dropped, or thrown
signal on_object_grab(obj: Node3D)
signal on_object_drop(obj: Node3D)
signal on_object_throw(obj: Node3D)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure that camera_raycast is set
	assert(camera_raycast != null, "camera_raycast must be explicitly set")
	pass # Replace with function body.

# Process function called every frame
func _process(delta):
	# Update the transforms and draw gizmos for surface sensors
	_update_transforms()
	dev.draw_gizmo_cube(self, "bottom-front-sensor", bottom_front_cast.to_global(Vector3.FORWARD / 2), Vector3(0.7, 0.7, 1), character.global_basis.z, Color.ORANGE if bottom_front_cast.is_colliding() else Color.PALE_GREEN)
	
	if top_front_cast.enabled:
		dev.draw_gizmo_cube(self, "top-front-sensor", top_front_cast.to_global(Vector3.FORWARD / 2), Vector3(0.7, 0.7, 1), character.global_basis.z, Color.ORANGE if top_front_cast.is_colliding() else Color.PALE_GREEN)
	else:
		dev.hide_gizmo(self, "top-front-sensor")
	pass
	
# Initialize the interaction manager with a GameCharacter
func initialize(_character: GameCharacter):
	character = _character
	add_exception(character)
	
	# Connect signals for crouch entered and exited events
	character.on_crouch_entered.connect(_enable_crouch_mode)
	character.on_crouch_exited.connect(_disable_crouch_mode)
	
	# Set initial position and parent for ceil_rayset
	ceil_rayset.position = Vector3.ZERO
	ceil_rayset.reparent(character.body_controller.head_anchor)

# Add exception for a node in all relevant sensors
func add_exception(node):
	camera_raycast.add_exception(node)
	
	if top_front_cast != null:
		top_front_cast.add_exception(node)
	
	if bottom_front_cast != null:
		bottom_front_cast.add_exception(node)
		
	if ceil_rayset != null:
		ceil_rayset.add_exception(node)

# Remove exception for a node from all relevant sensors
func remove_exception(node):
	camera_raycast.remove_exception(node)
	
	if top_front_cast != null:
		top_front_cast.remove_exception(node)
	
	if bottom_front_cast != null:
		bottom_front_cast.remove_exception(node)
		
	if ceil_rayset != null:
		ceil_rayset.remove_exception(node)

# Physics process function called every physics frame
func _physics_process(delta):
	# Check interactions with physical objects, walls, and ceiling
	_check_physical_object_in_hand(delta)
	_check_wall(delta)
	_check_ceil(delta)

# Update transforms for camera raycast
func _update_transforms():
	if character.camera_rig != null:
		var camera = character.camera_rig.get_camera()
		camera_raycast.global_position = camera.global_position
		camera_raycast.global_rotation = camera.global_rotation
		
# Check for collisions with walls
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
		
# Check for collisions with the ceiling
func _check_ceil(delta):
	var new_elevation_allowed: bool = true
	
	if ceil_rayset != null:
		ceil_rayset.global_position = character.body_controller.head_anchor.global_position + ceil_rayset_offset
		
		var obj = ceil_rayset.get_first_colliding_ray()
		if obj != null:
			new_elevation_allowed = false
	
	elevation_allowed = new_elevation_allowed
			
# Check the state of a physically held object
func _check_physical_object_in_hand(delta):
	if held_object != null:
		var hold_anchor = character.body_controller.hold_anchor
		var distance: float = held_object.global_position.distance_to(character.global_position)
		
		# Apply linear velocity to the held object based on hand manipulation
		held_object.linear_velocity = (hold_anchor.global_position - held_object.global_position) * character.props.hand_manipulation_pull_force * get_hand_manipulation_mass_penalty() * delta		
		hand_manipulation_close_grip = held_object.global_position.distance_to(hold_anchor.global_position) < character.props.hand_manipulation_close_grip_distance
		
		# If the distance exceeds the grab fail distance, stop grabbing
		if distance > app.config.character_physical_interaction_grab_fail_distance + app.config.character_physical_interaction_grab_max_distance:
			dev.logd("GameCharacterPhysicalInteractionManager", "hand manipulated item is missed due to distance")
			stop_grab()
				
	dev.print_screen("hand manipulation", "hand manip. target: %s" % ("none" if held_object == null else held_object.name))	
	dev.print_screen("hand manipulation mass penalty", "hand manip. penalty: %s" % tools.progress_to_percentage(get_hand_manipulation_mass_penalty()))
	
# Start grabbing a physically interactable object
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
				
				# Emit signal for grabbing an object
				on_object_grab.emit(held_object)
				hand_manipulation_close_grip = false
	
# Stop grabbing the currently held object
func stop_grab():
	if held_object != null:
		# Apply upward force to simulate dropping the object
		held_object.linear_velocity = Vector3.UP * character.props.hand_manipulation_drop_power * get_hand_manipulation_mass_penalty()
		# Emit signal for dropping an object
		on_object_drop.emit(held_object)
		app.tasks.stack_replace(self, "throw", 0.25, null, character.remove_collision_exception.bind(held_object))
		held_object = null
		is_holding_object = false
		
# Start throwing the currently held object
func start_throw():
	if held_object != null:
		# Calculate the throw direction based on camera ray
		var ray_direction = tools.get_global_forward_vector(camera_raycast)
		# Apply velocity to simulate throwing the object
		held_object.linear_velocity = (ray_direction + (Vector3.UP * character.props.hand_manipulation_throw_ballistics)).normalized() * character.props.hand_manipulation_throw_power * get_hand_manipulation_mass_penalty()
		
		app.tasks.stack_replace(self, "throw", 0.25, null, character.remove_collision_exception.bind(held_object))
		#character.remove_collision_exception(held_object)
		# Emit signal for throwing an object
		on_object_throw.emit(held_object)
		held_object = null
		is_holding_object = false
		
# Calculate the mass penalty for hand manipulation based on the held object's mass
func get_hand_manipulation_mass_penalty() -> float:
	if held_object != null:
		return 1. - clampf((held_object.mass / character.props.hand_manipulation_max_weight), 0, 1)
	else:
		return 0

# Enable crouch mode by disabling the top front sensor
func _enable_crouch_mode():
	top_front_cast.enabled = false
	
# Disable crouch mode by enabling the top front sensor
func _disable_crouch_mode():
	top_front_cast.enabled = true
