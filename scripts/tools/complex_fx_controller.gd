extends Node3D

class_name ComplexFXController

const MIN_VOLUME_LEVEL: float = -64
const MAX_VOLUME_LEVEL: float = 0

@export var cfx: RComplexFX
@export var self_destruct: bool = true
@export var volume_addent: float = 0
@export var pitch_multiplier: float = 1
@export var scale_multiplier: float = 1
@export var direction: Vector3 = Vector3.DOWN

var particle_systems: Array[GPUParticles3D] = []
var audio_players: Array[AudioStreamPlayer3D] = []
var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()
var _cooldowns: tools.CooldownManager = tools.CooldownManager.new()

var _decal_ray_cast: RayCast3D
var _decal_sphere_cast: ShapeCast3D
var _decal_sphere_cast_shape: SphereShape3D = load("res://resources/extra/shapes/sphere_1m.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	dev.logd("ComplexFXController","%s - init" % get_instance_id())
	if cfx != null:
		_spawn_cfx()
	
	_traverse(self)
	
	for ps in particle_systems:
		ps.emitting = true
		
	for pl in audio_players:
		if not pl.playing:
			pl.play()
	
	dev.logd("ComplexFXController", "found %s particle-systems" % particle_systems.size())
	dev.logd("ComplexFXController", "found %s audio-players" % audio_players.size())
	
	dev.set_label(self, tools.DataContainer.new({
		"default": "FX %s" % (cfx.name if cfx != null else "_")
	}))

func _exit_tree():
	dev.remove_label(self)

func setup(_cfx: RComplexFX, _volume_addent: float = 0, _pitch_multiplier: float = 1, _scale_multiplier: float = 1):
	dev.logd("ComplexFXController", "%s - setup" % get_instance_id())
	cfx = _cfx
	volume_addent = _volume_addent
	pitch_multiplier = _pitch_multiplier
	scale_multiplier = _scale_multiplier

func _traverse(node):
	# Call the callback function on the current node
	
	if node is GPUParticles3D:
		particle_systems.append(node)
		var ps = node as GPUParticles3D
		ps.scale *= scale_multiplier
		
	if node is AudioStreamPlayer3D:
		audio_players.append(node)	
		var pl = node as AudioStreamPlayer3D
		
		pl.volume_db += lerpf(-32, 32, (volume_addent / 2) + 0.5)
		pl.pitch_scale *= pitch_multiplier
	
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)

func _spawn_cfx():
	dev.logd("ComplexFXController","Spawning sfx %s" % cfx)
	if cfx.audio_fx_variants.size() > 0:
		_add_audio_fx(tools.get_random_element_from_array(cfx.audio_fx_variants))
		
	if cfx.particle_system_variants.size() > 0:
		_add_particle_system(tools.get_random_element_from_array(cfx.particle_system_variants))	
	pass
	
	if cfx.decal_fxs.size() > 0:
		for item in cfx.decal_fxs:
			_add_decal_fx(item)

func _add_decal_fx(props: RDecalFX):
	_cooldowns.start("decals-timeout", 10)
	
	var decal_position: Vector3 = global_position
	var decal_normal = -direction.normalized()
	var decal_props: RDecalSettings = tools.get_random_element_from_array(props.decals)
	
	match props.contact_type:
		RDecalFX.ERDecalContactType.Ray:
			if _decal_ray_cast == null:
				_decal_ray_cast = RayCast3D.new()
				_decal_ray_cast.collide_with_bodies = false
				_decal_ray_cast.collide_with_areas = false
				add_child(_decal_ray_cast)
				
			_decal_ray_cast.global_position = global_position - direction.normalized() / 2
			_decal_ray_cast.target_position = direction.normalized() * props.contact_trace_distance
			_decal_ray_cast.force_raycast_update()
			
			if _decal_ray_cast.is_colliding():
				if _decal_ray_cast.get_collider() is StaticBody3D:
					decal_position = _decal_ray_cast.get_collision_point()
					decal_normal = _decal_ray_cast.get_collision_normal()
			pass
			
			pass
		RDecalFX.ERDecalContactType.Sphere:	
			if _decal_sphere_cast == null:
				_decal_sphere_cast = ShapeCast3D.new()
				_decal_sphere_cast.collide_with_bodies = true
				_decal_sphere_cast.collide_with_areas = false
				_decal_sphere_cast.shape = _decal_sphere_cast_shape
				add_child(_decal_sphere_cast)
				
			_decal_sphere_cast.scale = Vector3.ONE * props.contact_trace_distance / 2
			_decal_sphere_cast.global_position = global_position
			_decal_sphere_cast.force_shapecast_update()
			
			if _decal_sphere_cast.is_colliding():
				for index in _decal_sphere_cast.get_collision_count():
					if _decal_sphere_cast.get_collider(index) is StaticBody3D:
						decal_position = _decal_sphere_cast.get_collision_point(index)
						decal_normal = _decal_sphere_cast.get_collision_normal(index)
			pass
		_:
			pass
				
	var decal: Decal = Decal.new()
	decal.size = Vector3(1, 0.2, 1)
	decal.texture_albedo = decal_props.albedo
	decal.texture_normal = decal_props.normal
	decal.albedo_mix = randf_range(decal_props.albedo_min, decal_props.albedo_max)
	
	decal.upper_fade = 2.0
	decal.lower_fade = 2.0
	
	add_child(decal)
	decal.force_update_transform()
	decal.global_position = decal_position
	decal.rotation_degrees.y = randf_range(decal_props.rotation_min, decal_props.rotation_max)
	decal.scale = Vector3.ONE * (randf_range(decal_props.scale_min, decal_props.scale_max))
	#decal.global_basis.y = decal_position - decal_normal
	if decal_normal != Vector3.UP:
		decal.look_at(decal_position + Vector3.UP, decal_normal)
	
	print('spawning decal: %s' % props)

func _add_audio_fx(audio_fx: RAudioFX):
	var new_audio_player = AudioStreamPlayer3D.new()
	
	new_audio_player.stream = tools.get_random_element_from_array(audio_fx.clips)
	new_audio_player.volume_db = lerpf(MIN_VOLUME_LEVEL, MAX_VOLUME_LEVEL, sqrt(randf_range(audio_fx.volume_min, audio_fx.volume_max)))
	new_audio_player.max_db = lerpf(MIN_VOLUME_LEVEL, MAX_VOLUME_LEVEL, sqrt(randf_range(audio_fx.volume_limit_min, audio_fx.volume_limit_max)))
	new_audio_player.pitch_scale = randf_range(audio_fx.pitch_min, audio_fx.pitch_max)
	new_audio_player.max_distance = audio_fx.max_distance
	new_audio_player.attenuation_model = audio_fx.attenuation_mode
	new_audio_player.panning_strength = audio_fx.panning_strength
	new_audio_player.seek(randf_range(audio_fx.start_at_min, audio_fx.start_at_max))
	
	add_child(new_audio_player)

func _add_particle_system(data: PackedScene):
	var node: Node3D = data.instantiate()
	add_child(node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _timer_gate.check("health", 1):
		check_tasks()
	
	dev.draw_gizmo_ray(self, 'cfx-direction', global_position, global_position - direction, Color.PURPLE)	
		
	for ap in audio_players:
		if ap.max_distance > 0:
			dev.draw_gizmo_sphere(self, 'audio-player%s' % ap.get_instance_id(), ap.global_position, ap.max_distance, Color.CORAL)
			


func check_tasks():
	var active_particle_systems = 0
	var active_audio_players = 0
	
	for ps in particle_systems:
		if ps.emitting:
			active_particle_systems += 1
			
	for pl in audio_players:
		if pl.playing:
			active_audio_players += 1		
			
			
	if self_destruct and (not _cooldowns.exists("decals-timeout") or _cooldowns.ready("decals-timeout")):
		if active_particle_systems == 0 and active_audio_players == 0:
			dev.logd("ComplexFXController", "self destructing...")
			queue_free()
