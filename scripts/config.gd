extends Resource

class_name RGameConfig

@export var name: String = "Some Game Config"
@export var default_collision_cfx: RComplexFX

@export_subgroup("Scene Importing")
@export var imported_omnilight_energy_scale: float = 0.000025
@export var imported_omnilight_max_range: float = 48
@export var imported_spotlight_energy_scale: float = 0.0005
@export var imported_spotlight_max_range: float = 48

@export_group("Debug Settings")
@export var dev_labels_view_distance: float = 128



func _init():
	pass
