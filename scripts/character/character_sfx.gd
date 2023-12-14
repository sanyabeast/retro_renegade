extends Node3D

class_name CharacterSFX

@export var profile: RCharacterSFXProfile

@export_subgroup("Reference")
@export var character: GameCharacter
@export var jump_audiostream: AudioStreamPlayer3D
@export var footsteps_audiostream: AudioStreamPlayer3D

enum EActionType {
	JumpStart,
	Landing,
	Walk,
	Sprint,
	ClimbStart
}

var _timer_gate = tools.TimerGateManager.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if footsteps_audiostream != null and profile.footsteps_audioclip != null:
		footsteps_audiostream.stream = profile.footsteps_audioclip
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass	
	
func commit_action(action_type: EActionType, strength: float = 1, speed: float = 1):
	match action_type:
		EActionType.JumpStart:
			if _timer_gate.check("jump_sfx", profile.jump_play_timeout):
				world.play_audio_fx(profile.jump_audio_fx, global_position, 0, 1)
		EActionType.Landing:
			if strength > 0.1:
				world.play_audio_fx(profile.landing_audio_fx, global_position, (pow(strength, 2) - 1), 1)	
		EActionType.Walk:
			#var speed_progress = clampf(Vector2(character.velocity.x, character.velocity.z).length() / character.props.walk_speed_max, 0, 1)
			footsteps_audiostream.volume_db = lerpf(profile.footsteps_volume_min, profile.footsteps_volume_max, strength)
			footsteps_audiostream.pitch_scale = lerpf(profile.footsteps_pitch_min, profile.footsteps_pitch_max, strength)
			
			if strength > 0.1 and not footsteps_audiostream.playing:
				footsteps_audiostream.play()
				
			if strength <= 0.1 and footsteps_audiostream.playing:
				footsteps_audiostream.stop()
