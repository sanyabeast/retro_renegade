extends Node

class_name WorldManager

var level: GameLevel
var env: WorldEnvironmentController
var rigid_bodies: Array[RigidBody3D] = []
var rigid_bodies_timer_gates: Dictionary = {}
var sound_players: Array[AudioStreamPlayer3D] = []

func add_rigidbody(body: RigidBody3D):
	
	body.contact_monitor = true
	body.max_contacts_reported = 1
	rigid_bodies_timer_gates[body] = tools.TimerGateManager.new()
	body.connect("body_entered", handle_rigidbody_collided.bind(body))
	body.connect("tree_exited", check_rigidbodies.bind(body))
	
	rigid_bodies.append(body)
	
func check_rigidbodies(rigidbody: RigidBody3D):
	rigid_bodies_timer_gates.erase(rigidbody)
	rigid_bodies.remove_at(rigid_bodies.find(rigidbody))
	
	for rb in rigid_bodies:
		rb.sleeping = false

func handle_rigidbody_collided(target: Node3D, rigidbody: RigidBody3D):
	play_collision_sound(rigidbody.global_position, rigidbody, target)

func set_level(_level: GameLevel):
	print("World: level set to: %s" % _level.name)
	level = _level
	
func unset_level(_level: GameLevel):
	if level == _level:
		print("World: level unset: %s" % _level.name)
		level = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dev.print_screen("rigids", "registred rigidbodies: %s" % rigid_bodies.size())
	pass

func play_sound_at_position(audio_stream: AudioStreamOggVorbis, position: Vector3, volume: float, pitch: float = 1):
	var audio_player = AudioStreamPlayer3D.new()
	add_child(audio_player)  # Add it to the scene

	# Load the audio file
	audio_player.stream = audio_stream
	audio_player.volume_db = volume
	audio_player.pitch_scale = pitch

	# Set the position
	audio_player.global_transform.origin = position

	# Play the sound
	audio_player.play()

	# Optional: Automatically remove the node after playback
	audio_player.connect("finished", check_sound_players)

func check_sound_players():
	print("checking snds")
	var active_sounds: Array[AudioStreamPlayer3D] = []
	var finished_sounds: Array[AudioStreamPlayer3D] = []
	
	for item in sound_players:
		if item.finished:
			finished_sounds.append(item)
		else:
			active_sounds.append(item)
	
	for _sound in finished_sounds:
		_sound.queue_free()		
			
	sound_players = active_sounds
	
	for rb in sound_players:
		rb.sleeping = false

func play_collision_sound(position: Vector3, body: RigidBody3D, target: Node3D):
	
	if env == null:
		print("setup WorldEnvironmentController to play collision sounds")
		return
	else:
		print("playing collision between %s and %s" % [body.name, target.name])
		
		if rigid_bodies_timer_gates[body].check("collision_sound", 0.25):
			var mass_progress = clampf(body.mass / 32, 0, 1)
			var velocity_progress = clampf(body.linear_velocity.length() / 10, 0, 1)
			
			if velocity_progress > 0.05 and mass_progress > 0.01:
				var volume = lerpf(-16, 0, pow(velocity_progress, 2))
				var pitch = lerpf(2, 0.5, pow(mass_progress, 2))
				play_sound_at_position(env.default_collision_sound, position, volume, pitch)
