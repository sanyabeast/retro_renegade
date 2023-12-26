extends Node

class_name PlayerManager

var spawn_spots: Array[Node3D] = []
var current: GameCharacter = null

enum EInputMode {
	App,
	CharacterControl,
	DontOverride
}

var input_mode: EInputMode = EInputMode.CharacterControl
var input_mode_override: EInputMode = EInputMode.App

func set_player(character: GameCharacter):
	current = character
	camera_manager.set_camera(current.get_camera())
	
func add_spawn_spot(node: Node3D):
	dev.logd("PlayerManager", "adding new spawn spot: %s" % node.name)
	spawn_spots.append(node)

func allow_npc(character: GameCharacter):
	return not (character == current)

func remove_all_spawn_spots():
	spawn_spots = []
	dev.logd("PlayerManager", "removing all spawn spots")

func remove_spawn_spot(node: Node3D):
	dev.logd("PlayerManager", "removing new spawn spot: %s" % node.name)
	var index = spawn_spots.find(node)
	if index > -1:
		spawn_spots.remove_at(index)
	
func respawn_player(position = null):
	if current != null:
		dev.logd("PlayerManager", "freeing current player")
		current.queue_free()
		
	if world.level == null:
		dev.logd("PlayerManager", "FAILED to respawn player: no world.level set")
		return
	if world.level.settings.player_default_class == null:
		dev.logd("PlayerManager", "FAILED to respawn player: no world.level.default_player set")
		return
	if spawn_spots.size() == 0:
		dev.logd("PlayerManager", "FAILED to respawn player: no spawn_spots")
		return	
	
	var spawn_position = position
	var spawn_rotation = Vector3.ZERO
	
	if spawn_position == null:
		var _spot: Node3D = tools.get_random_element_from_array(spawn_spots)
		spawn_position = _spot.global_position
		spawn_rotation = _spot.rotation_degrees
		 	
	var player = tools.spawn_object_with_position_and_roation(world.level.settings.player_default_class, spawn_position, spawn_rotation, world.level)
	set_player( player)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_mouse_mode()
	
	if current != null and dev != null:
		dev.print_screen("character_pos", "character xyz: %s" % current.global_position)
		dev.print_screen("character_vel", "character velocity: %.2f m/s" % current.velocity.length())
		dev.print_screen("character_crouch", "character crouching: %s" % current.is_crouching)
		dev.print_screen("character_travelled", "character travelled: %.2f m" % current.travelled)
		dev.print_screen("character_jump_charge", "character jump charge: %.2f m" % current.cooldowns.progress("jump_charge"))
		dev.print_screen("character_air_travelled", "character travelled (air): %.2f m" % current.air_travelled)
		dev.print_screen("character_ground_travelled", "character travelled (ground): %.2f m" % current.ground_travelled)
		dev.print_screen("character_air_time", "character time (air): %.2f s" % current.air_time)
		dev.print_screen("character_ground_time", "character time (ground): %.2f s" % current.ground_time)
		dev.print_screen("character_travelled_climb", "character travelled climbing: %.2f m" % ((current.travelled - current.climbing_start_distance) if current.is_climbing else 0))
		dev.print_screen("character_dirvel", "character direcional velocity: %.2f m" % current.body_controller._current_character_directional_velocity)

func _physics_process(delta):
	process_user_input()
	
func update_mouse_mode():
	var _input_mode = input_mode if input_mode_override == EInputMode.DontOverride else input_mode_override
	
	match _input_mode:
		EInputMode.App:
			if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		EInputMode.CharacterControl:
			if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func process_user_input():
	var _input_mode = input_mode if input_mode_override == EInputMode.DontOverride else input_mode_override
	
	match _input_mode:
		EInputMode.App:
			pass
		EInputMode.CharacterControl:
			if current != null:
				var props: RCharacterProperties = current.props
				# CLIMBING
				if props.allow_climbing:
					if Input.is_action_pressed('jump'):
						current.start_climb()
					
				# JUMPING
				if props.allow_jump:
					if Input.is_action_just_released("jump"):
						current.finish_jump()	
					else:
						if Input.is_action_pressed('jump'):
							current.start_jump()
						else:
							current.cancel_jump()
					
				# SPRINGING
				if props.allow_sprint:
					if props.flip_sprint_walk:
						if Input.is_action_pressed("sprint"):
							current.stop_sprint()
						else:
							current.start_sprint()
					else:
						if Input.is_action_pressed("sprint"):
							current.start_sprint()
						else:
							current.stop_sprint()
				# CROUCHING
				if Input.is_action_pressed("crouch"):
					current.start_crouch()
				if not Input.is_action_pressed("crouch"):
					current.stop_crouch()
					
				# PHYSICAL INTERACTION
				if Input.is_action_just_pressed("grab"):
					current.start_grab()
				
				if not Input.is_action_pressed("grab"):
					current.stop_grab()
					
				if Input.is_action_just_pressed("throw"):
					current.start_throw()
					
				# MOVEMENT DIRECTION AND TARGET SPEEDS
				var movement_direction: Vector3 = Vector3.ZERO

				if Input.is_action_pressed("forward"):
					movement_direction -= current.global_transform.basis.z
				if Input.is_action_pressed("backward"):
					movement_direction +=  current.global_transform.basis.z
				if Input.is_action_pressed("right"):
					movement_direction +=  current.global_transform.basis.x
				if Input.is_action_pressed("left"):
					movement_direction -=  current.global_transform.basis.x
					
				current.set_movement_direction(movement_direction)	

				# EXTRAS
				if Input.is_action_just_pressed("ui_cancel"):
					if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
						input_mode_override = EInputMode.App

				if Input.is_action_just_pressed("torch"):
					current.set_torch_visible(not current.is_torch_visible())

				# DEV
				if Input.is_action_just_pressed("dev0"):
					if current.body_physics_enabled:
						current.stop_body_physics()
					else:
						current.start_body_physics()
			

func _input(event):
	if current != null:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			current.process_camera_input(event)
			
		if event is InputEventMouseButton:
			if input_mode_override != EInputMode.DontOverride and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				input_mode_override = EInputMode.DontOverride
