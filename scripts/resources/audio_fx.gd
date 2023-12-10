extends Resource

class_name RAudioFX

@export var clips: Array[AudioStreamOggVorbis] = []

@export var max_distance: float = 8

@export var volume_min: float = 1
@export var volume_max: float = 1

@export var volume_limit_min: float = 1
@export var volume_limit_max: float = 1

@export var pitch_min: float = 1
@export var pitch_max: float = 1

@export var panning_strength: float = 0.5

@export var attenuation_mode: AudioStreamPlayer3D.AttenuationModel

