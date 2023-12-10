extends Node3D

class_name WorldEnvironmentController

@export var settings: RWorldEnvSettings

@export_subgroup("REFERENCIES")
@export var dir_light: DirectionalLight3D
@export var world_env: WorldEnvironment
@export var world_ambient_stream: AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready():
	world.set_environment(self)
	
	print("KEKEKEK %s" % world_ambient_stream)
	if world_ambient_stream != null and settings.ambient_sound != null:
		tools.play_audio_fx(world_ambient_stream, settings.ambient_sound)
		pass
	
	pass # Replace with function body.

func _exit_tree():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if settings.day_cycle_enabled:
		dir_light.global_rotation = get_sun_rotation()
		#dir_light.light_energy = get_sun_energy(world.day_time)
		dir_light.light_color = Color.from_hsv(
			lerpf(settings.sun_hue_night, settings.sun_hue_day, get_sun_progress2()),
			lerpf(settings.sun_saturation_night, settings.sun_saturation_day, get_sun_progress2()),
			1
		)
		
		#world_env.environment.volumetric_fog_density = lerpf(fog_density_night, fog_density_day, get_sun_progress())
		world_env.environment.background_energy_multiplier = lerpf(settings.sky_energy_night, settings.sky_energy_day, get_sun_progress())
		#dir_light.global_rotation.z = sin(world.day_time)
		#dir_light.rotate_z(((1 / day_cycle_length) * 360) * delta)
		#dir_light.rotate_y(((1 / day_cycle_length) * 720) * delta)
	pass
	
func get_sun_progress():
	return sqrt((-sin((world.day_time) * 2.0 * PI) + 1) / 2)
	
func get_sun_progress2():
	return sqrt(clamp(-sin((world.day_time) * 2.0 * PI), 0, 1))
# Converts game time (0-1) to sun rotation
# 0 = midnight, 0.25 = sunrise, 0.5 = noon, 0.75 = sunset, 1 = next midnight
func get_sun_rotation() -> Vector3:
	# Ensure game_time is in the range [0, 1]

	# Map the game time to a full circle in radians
	# We use a sine wave to simulate the sun's arc in the sky
	# Adjust these values if you need a different sun path
	var sun_azimuth = world.day_time * 360.0  # 60 degrees arc
	var sun_atitude = sin((world.day_time) * PI * 2.0) * 60.

	# Assuming the sun rises in the East (+Y) and sets in the West (-Y)
	# Rotating around the X-axis
	return Vector3(deg_to_rad(sun_atitude), deg_to_rad(sun_azimuth), 0)

func get_sun_energy() -> float:
	return lerpf(0.5, 1 , max(0.0, sin((world.day_time + 0.5) * 2.0 * PI)))
