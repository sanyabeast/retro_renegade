extends Node3D

class_name WorldEnvironmentController

@export var settings: RWorldEnvSettings

@export_subgroup("Referencies")
@export var world_environment: WorldEnvironment
@export var sun: DirectionalLight3D

signal on_before_travel(scene_path: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_tree(self)
	world.set_environment(self)
	if settings.ambient_sound != null:
		dev.logd("WorldEnvironmentController", settings.ambient_sound.clips)
		world.play_audio_fx(settings.ambient_sound, global_position, 0, 1)
		pass
	
# Replace with function body.
func _exit_tree():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if settings.day_cycle_enabled:
		sun.global_rotation = get_sun_rotation()
		#sun.light_energy = get_sun_energy(world.day_time)
		sun.light_color = Color.from_hsv(
			lerpf(settings.sun_hue_night, settings.sun_hue_day, get_sun_progress2()),
			lerpf(settings.sun_saturation_night, settings.sun_saturation_day, get_sun_progress2()),
			1
		)
		
		world_environment.environment.background_energy_multiplier = lerpf(settings.sky_energy_night, settings.sky_energy_day, get_sun_progress())
		#dir_light.global_rotation.z = sin(world.day_time)
	pass
	
func _setup_tree(node):
	# Call the callback function on the current node
	
	if world_environment == null and node is WorldEnvironment:
		world_environment = node	
	
	if sun == null and node is DirectionalLight3D:
		sun = node		
		
	# Recursively call this function on all children
	for child in node.get_children():
		_setup_tree(child)
	
func get_sun_progress():
	return sqrt((-sin((world.day_time + 0.25) * 2.0 * PI) + 1) / 2)
	
func get_sun_progress2():
	return sqrt(clamp(-sin((world.day_time + 0.25) * 2.0 * PI), 0, 1))
	
func get_sun_rotation() -> Vector3:
	var sun_azimuth = world.day_time * 360.0  # 60 degrees arc
	var sun_atitude = clampf(sin((world.day_time + 0.25) * PI * 2.0) * 2, -1., 1.) * 60.
	return Vector3(deg_to_rad(sun_atitude), deg_to_rad(sun_azimuth), 0)

func get_sun_energy() -> float:
	return lerpf(0.5, 1 , max(0.0, sin((world.day_time + 0.25) * 2.0 * PI)))

func travel(scene_path: String):
	on_before_travel.emit(scene_path)
	tools.load_scene(scene_path)
