extends Resource

class_name RCharacterSFXProfile

@export var landing_audio_fx: RAudioFX

@export_subgroup("Footsteps SFX")

@export var footsteps_audioclip: AudioStreamOggVorbis
@export var footsteps_volume_min: float = -32
@export var footsteps_volume_max: float = -24
@export var footsteps_pitch_min: float = 0.75
@export var footsteps_pitch_max: float = 1.5

@export_subgroup("Jump SFX")
@export var jump_audio_fx: RAudioFX
@export var jump_play_timeout: float = 0.15


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
