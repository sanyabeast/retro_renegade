extends Node3D

@export var player: GameCharacter

@export_subgroup("Footsteps SFX")
@export var footsteps_audiostream: AudioStreamPlayer3D
@export var footsteps_audioclip: AudioStreamOggVorbis
#@export var footsteps_volume_min: float = -32
#@export var footsteps_volume_max: float = -24
@export var footsteps_pitch_min: float = 0.75
@export var footsteps_pitch_max: float = 1.5

@export_subgroup("Jump SFX")
@export var jump_audiostream: AudioStreamPlayer3D
@export var jump_audio_fx: RAudioFX
@export var jump_play_timeout: float = 0.15

var _timer_gate = tools.TimerGateManager.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if footsteps_audiostream != null and footsteps_audioclip != null:
		footsteps_audiostream.stream = footsteps_audioclip
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
# WALKING
	if player.is_on_floor():
		var sprint_progress = clampf(Vector2(player.velocity.x, player.velocity.z).length() / player.props.sprint_speed_max, 0, 1)
		#footsteps_audiostream.volume_db = lerpf(footsteps_volume_min, footsteps_volume_max, sprint_progress)
		footsteps_audiostream.pitch_scale = lerpf(footsteps_pitch_min, footsteps_pitch_max, sprint_progress)
		
		if sprint_progress > 0.1 and not footsteps_audiostream.playing:
			footsteps_audiostream.play()
			
		if sprint_progress <= 0.1 and footsteps_audiostream.playing:
			footsteps_audiostream.stop()	
	else:
		footsteps_audiostream.stop()		
	
# JUMPING
	if player.current_jump_power == 1 and _timer_gate.check("jump", jump_play_timeout):
		world.play_audio_fx(jump_audio_fx, global_position, 0, 1)
	
	pass
