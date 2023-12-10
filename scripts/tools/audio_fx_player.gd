extends AudioStreamPlayer3D

class_name AudioFXPlayer

@export var audio_fxs: Array[RAudioFX] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if audio_fxs.size() > 0:
		tools.play_audio_fx(self, tools.get_random_element_from_array(audio_fxs))
