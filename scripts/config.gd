extends Resource

class_name RGameConfig

@export var name: String = "Some Game Config"
@export var default_collision_cfx: RComplexFX

@export_group("Debug Settings")
@export var dev_labels_view_distance: float = 64

func _init():
	pass
