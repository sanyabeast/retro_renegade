extends Node

class_name TreeParser

var player_spawn_spots: Array[Node3D] = []
var rigid_bodies: Array[RigidBody3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	_traverse(self)
	dev.logd("TreeParser", "found %s player spawns" % [player_spawn_spots.size()])
	for _ps in player_spawn_spots:
		players.add_spawn_spot(_ps)
		

func _exit_tree():
	#dev.logd(TreeParser: exits tree")
	for _ps in player_spawn_spots:
		players.remove_spawn_spot(_ps)
	pass
	
func _process(delta):
	pass

func _traverse(node):
	_process_node(node)
	for child in node.get_children():
		_traverse(child)
		
func _process_node(node: Object):
	var props = tools.parse_properties(node.name)
	
	if node is RigidBody3D:
		world.add_rigidbody(node)
	
	if "spawn" in props:
		process_spawn_node(node, props)
	
	if "mass" in props:
		if node.get_parent() is RigidBody3D:
			node.get_parent().mass = float(props["mass"])
	

func process_spawn_node(node, props):
	match props["spawn"]:
		"player":
			player_spawn_spots.append(node)
			pass
