extends Resource

class_name RDecalSettings
	
@export var albedo: Texture2D
@export var albedo_min: float = 1.0
@export var albedo_max: float = 1.0
@export var normal: Texture2D

@export_subgroup("Extra Textures")
@export var emission: Texture2D
@export var orm: Texture2D

@export_subgroup("Values")
@export var emission_energy: float = 1
@export var modulate: Color = Color.WHITE

@export_subgroup("Randomize Transformations")
@export var rotation_min: float = -180
@export var rotation_max: float = 180
@export var scale_min: float = 0.5
@export var scale_max: float = 1
