extends Node3D

class_name ComplexFXController

const MIN_VOLUME_LEVEL: float = -64
const MAX_VOLUME_LEVEL: float = 0

@export var cfx: RComplexFX
@export var self_destruct: bool = true
@export var volume_addent: float = 0
@export var pitch_multiplier: float = 1
@export var scale_multiplier: float = 1

var particle_systems: Array[GPUParticles3D] = []
var audio_players: Array[AudioStreamPlayer3D] = []
var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()

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
		print("volume added", volume_addent)
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

func check_tasks():
	var active_particle_systems = 0
	var active_audio_players = 0
	
	for ps in particle_systems:
		if ps.emitting:
			active_particle_systems += 1
			
	for pl in audio_players:
		if pl.playing:
			active_audio_players += 1		
			
			
	if self_destruct:
		if active_particle_systems == 0 and active_audio_players == 0:
			dev.logd("ComplexFXController", "self destructing...")
			queue_free()
