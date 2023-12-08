extends Node3D

class_name WorldEnvironmentController

@export var day_cycle_enabled: bool = true
@export var day_cycle_length: float = 60

@onready var dir_light: DirectionalLight3D = $DirectionalLight3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if day_cycle_enabled:
		dir_light.global_rotation = get_sun_rotation(game.game_time)
		dir_light.light_energy = get_sun_energy(game.game_time)
		#dir_light.global_rotation.z = sin(game.game_time)
		#dir_light.rotate_z(((1 / day_cycle_length) * 360) * delta)
		#dir_light.rotate_y(((1 / day_cycle_length) * 720) * delta)
	pass

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

func get_sun_energy(game_time: float) -> float:
	return lerpf(0.5, 1 , max(0.0, sin((game_time + 0.5) * 2.0 * PI)))
