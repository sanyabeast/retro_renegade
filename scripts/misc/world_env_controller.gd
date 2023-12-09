extends Node3D

class_name WorldEnvironmentController



@export var dir_light: DirectionalLight3D
@export var world_env: WorldEnvironment
@export var world_ambient_stream: AudioStreamPlayer3D

@export_subgroup("Day Cycle")
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

@export_subgroup("Sounds")
@export var default_collision_sound: AudioStreamOggVorbis

# Called when the node enters the scene tree for the first time.
func _ready():
	world.env = self
	pass # Replace with function body.

func _exit_tree():
	if world.env == self:
		world.env = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if day_cycle_enabled:
		dir_light.global_rotation = get_sun_rotation(game.game_time)
		#dir_light.light_energy = get_sun_energy(game.game_time)
		dir_light.light_color = Color.from_hsv(
			lerpf(sun_hue_night, sun_hue_day, get_sun_progress2()),
			lerpf(sun_saturation_night, sun_saturation_day, get_sun_progress2()),
			1
		)
		
		#world_env.environment.volumetric_fog_density = lerpf(fog_density_night, fog_density_day, get_sun_progress())
		world_env.environment.background_energy_multiplier = lerpf(sky_energy_night, sky_energy_day, get_sun_progress())
		#dir_light.global_rotation.z = sin(game.game_time)
		#dir_light.rotate_z(((1 / day_cycle_length) * 360) * delta)
		#dir_light.rotate_y(((1 / day_cycle_length) * 720) * delta)
	pass
	
func get_sun_progress():
	return sqrt((-sin((game.game_time) * 2.0 * PI) + 1) / 2)
	
func get_sun_progress2():
	return sqrt(clamp(-sin((game.game_time) * 2.0 * PI), 0, 1))
# Converts game time (0-1) to sun rotation
# 0 = midnight, 0.25 = sunrise, 0.5 = noon, 0.75 = sunset, 1 = next midnight
func get_sun_rotation(game_time: float) -> Vector3:
	# Ensure game_time is in the range [0, 1]

	# Map the game time to a full circle in radians
	# We use a sine wave to simulate the sun's arc in the sky
	# Adjust these values if you need a different sun path
	var sun_azimuth = game_time * 360.0  # 60 degrees arc
	var sun_atitude = sin((game_time) * PI * 2.0) * 60.

	# Assuming the sun rises in the East (+Y) and sets in the West (-Y)
	# Rotating around the X-axis
	return Vector3(deg_to_rad(sun_atitude), deg_to_rad(sun_azimuth), 0)

func get_sun_energy() -> float:
	return lerpf(0.5, 1 , max(0.0, sin((game.game_time + 0.5) * 2.0 * PI)))
