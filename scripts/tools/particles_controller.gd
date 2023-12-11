extends Node3D

class_name ParticlesController

@export var self_destruct: bool = true

var particle_systems: Array[GPUParticles3D] = []
var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	traverse(self)
	
	for ps in particle_systems:
		ps.emitting = true
	
	print("ParticlesController: found %s particle-systems" % particle_systems.size())
	pass # Replace with function body.

func traverse(node):
	# Call the callback function on the current node
	
	if node is GPUParticles3D:
		particle_systems.append(node)
	
	# Recursively call this function on all children
	for child in node.get_children():
		traverse(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _timer_gate.check("health", 1):
		check_tasks()

func check_tasks():
	var active_particle_systems = 0
	
	for ps in particle_systems:
		if ps.emitting:
			active_particle_systems += 1
			
	if self_destruct and active_particle_systems == 0:
		print("ParticlesController: self destructing")
		queue_free()
