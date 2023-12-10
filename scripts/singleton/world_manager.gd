extends Node

class_name WorldManager

var level: GameLevel
var env: WorldEnvironmentController
var rigid_bodies: Array[RigidBody3D] = []
var rigid_bodies_timer_gates: Dictionary = {}


var day_time: float = 0
var day_duration: float = 24 * 60 * 60

func set_environment(_env: WorldEnvironmentController):
	env = _env
	day_time = env.settings.day_time
	day_duration = env.settings.day_duration
	
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
	day_time += delta / day_duration;
	dev.print_screen("rigids", "registred rigidbodies: %s" % rigid_bodies.size())
	dev.print_screen("day_time", "game time: %s" % day_time)
	pass

func play_collision_sound(position: Vector3, body: RigidBody3D, target: Node3D):
	
	if env == null:
		print("setup WorldEnvironmentController to play collision sounds")
		return
	else:
		print("playing collision between %s and %s" % [body.name, target.name])
		
		if rigid_bodies_timer_gates[body].check("collision_sound", 0.1):
			var mass_progress = clampf(body.mass / 32, 0, 1)
			var velocity_progress = clampf(body.linear_velocity.length() / 10, 0, 1)
			
			if velocity_progress > 0.05 and mass_progress > 0.01:
				var volume = lerpf(-16, -8, pow(velocity_progress, 2))
				var pitch = lerpf(1.25, 0.75, pow(mass_progress, 2))
				tools.play_sound_at_position(env.settings.default_collision_sound, position, volume, pitch)
