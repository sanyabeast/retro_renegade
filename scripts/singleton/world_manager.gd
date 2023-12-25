extends Node

class_name WorldManager

const MIN_IMPACT_STRENGTH: float = 0.01
const MAX_IMPACTS_PER_SECOND_FOR_OBJECT: float = 5

var level: GameLevel
var env: WorldEnvironmentController
var rigid_bodies: Array[RigidBody3D] = []
var _rigid_bodies_timer_gates: Dictionary = {}

var day_time: float = 0
var day_duration: float = 24 * 60 * 60

var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()
var _fx_id: int = 0

var characters: Array[GameCharacter] = []

# LIFECYCLE
func _ready():
	pass # Replace with function body.

func _process(delta):
	day_time += delta / day_duration;
	day_time = fmod(day_time, 1)
	dev.print_screen("rigids", "rigid bodies: %s pts" % rigid_bodies.size())
	dev.print_screen("daytime", "day time: %s" % get_daytime_formatted_to_24h())
	pass

func link_character(character: GameCharacter):
	dev.logd("WorldManager", "linking character: %s" % character.name)
	characters.append(character)

func unlink_character(character: GameCharacter):
	dev.logd("WorldManager", "unlinking character: %s" % character.name)
	characters.remove_at(characters.find(character))

# METHODS
func set_environment(_env: WorldEnvironmentController):
	env = _env
	day_time = env.settings.day_time
	day_duration = env.settings.day_duration
	
func add_rigidbody(body: RigidBody3D):
	body.contact_monitor = true
	body.max_contacts_reported = 1
	_rigid_bodies_timer_gates[body] = tools.TimerGateManager.new()
	body.connect("body_entered", _handle_rigidbody_collided.bind(body))
	body.connect("tree_exited", _check_rigidbodies.bind(body))
	
	rigid_bodies.append(body)


func set_level(_level: GameLevel):
	dev.logd("WorldManager", "World: level set to: %s" % _level.name)
	players.spawn_spots = []
	
	if _level != null:
		_level.bounds.disconnect("body_exited", handle_world_bounds_exit)
	
	level = _level
	level.bounds.connect("body_exited", handle_world_bounds_exit)
	_init_node_tree(level)

func handle_world_bounds_exit(body: Node3D):
	if body is GameCharacter:
		body.global_position = tools.get_random_element_from_array(players.spawn_spots).global_position
	elif body is RigidBody3D:
		body.queue_free()
	
func unset_level(_level: GameLevel):
	if level == _level:
		dev.logd("WorldManager", "World: level unset: %s" % _level.name)
		level = null

# FX
func play_audio_fx(audio_fx: RAudioFX, position: Vector3, volume_addent: float = 1, pitch_multiplier: float = 1):
	# Load the audio file
	var complex_fx: RComplexFX = RComplexFX.new()
	complex_fx.name = audio_fx.name
	complex_fx.audio_fx_variants = [audio_fx]
	spawn_cfx(complex_fx, position, volume_addent, pitch_multiplier, 1)

# COMPLEX FX
func spawn_cfx(cfx: RComplexFX, position: Vector3, volume_addent: float = 0, pitch_multiplier: float = 1, scale_multiplier: float = 1):
	assert(env != null, "WorldEnvironmentController must be present on scene to spawn fx")
	var cfx_node: ComplexFXController = ComplexFXController.new()
	cfx_node.setup(cfx, volume_addent, pitch_multiplier, scale_multiplier)
	cfx_node.global_position = position
	cfx_node.name = "CFX %s %s" % [cfx.name, _fx_id]
	env.add_child(cfx_node)
	_fx_id += 1
	pass

# CALLBACKS
func _check_rigidbodies(rigidbody: RigidBody3D):
	_rigid_bodies_timer_gates.erase(rigidbody)
	rigid_bodies.remove_at(rigid_bodies.find(rigidbody))
	
	for rb in rigid_bodies:
		rb.sleeping = false

func _handle_rigidbody_collided(target: Node3D, body: RigidBody3D):
	if _rigid_bodies_timer_gates[body].check("colfx", 1/MAX_IMPACTS_PER_SECOND_FOR_OBJECT):
		var contact_point = body.global_position
		
		if body.get_contact_count() > 0:
			var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(body)
			contact_point = state.get_contact_local_position(0)
		
		var impact_strength = pow(clampf((body.linear_velocity.length() / sqrt(body.mass)) / 8, 0, 1), 2)
		if impact_strength > MIN_IMPACT_STRENGTH:
			spawn_cfx(app.config.default_collision_cfx, contact_point, 1, 1, 1)

# tools
func get_daytime_formatted_to_24h()->String:
	var total_minutes = int(day_time * 24 * 60)
	var hours = total_minutes / 60
	var minutes = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]

func _init_node_tree(node):
	if node != null:
		_process_node(node)
		for child in node.get_children():
			_init_node_tree(child)
		
func _process_node(object: Object):
	if object is Node3D:
		var node_props = ImportScript.parse_properties(object.name)
		if "player_spawn" in node_props:
			players.add_spawn_spot(object)
		pass
		
		if object is RigidBody3D:
			add_rigidbody(object)
	
