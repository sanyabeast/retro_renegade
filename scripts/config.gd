extends Resource

class_name RGameConfig

@export var name: String = "Some Game Config"
@export var default_collision_cfx: RComplexFX

@export_subgroup("Scene Importing")
@export var imported_omnilight_energy_scale: float = 0.00005
@export var imported_omnilight_max_range: float = 32
@export var imported_spotlight_energy_scale: float = 0.0005
@export var imported_spotlight_max_range: float = 32

@export_subgroup("Controls Settings")
@export var first_person_camera_sensitivity: float = 0.1 
@export var third_person_camera_sensitivity: float = 0.05

@export_subgroup("Character")
@export var character_physical_interaction_grab_max_distance: float = 2.5
@export var character_physical_interaction_grab_fail_distance: float = 0.3

@export_subgroup("FX")
@export var base_decal_scene: PackedScene = preload("res://scenes/base_decal.tscn")

@export_subgroup("Debug Settings")
@export var dev_labels_view_distance: float = 64

@export_subgroup("HUD")
@export var hud_default_state_in_game: Array[String] = ['in-game-hud']
@export var hud_default_state_paused: Array[String] = ['pause-menu']

func _init():
	pass
