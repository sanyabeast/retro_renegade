extends Resource

class_name RWorldEnvSettings

@export var name: String = "Some World Environment"

@export_subgroup("Day Cycle")
@export var day_duration: float = 60
@export var day_time: float = 0.5

@export var day_cycle_enabled: bool = true
@export var day_cycle_length: float = 60

@export var fog_density_night: float = 0.1
@export var fog_density_day: float = 0.01

@export var sky_energy_night: float = 0.15
@export var sky_energy_day: float = 1

@export var sun_hue_day: float = 1.1
@export var sun_hue_night: float = 0.95

@export var sun_saturation_day: float = 0.333
@export var sun_saturation_night: float = 0.666

@export_subgroup("Ambient FX")
@export var ambient_sound: RAudioFX


