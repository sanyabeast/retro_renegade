extends Node

class_name TreeParser

var player_spawn_spots: Array[Node3D] = []
var rigid_bodies: Array[RigidBody3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	traverse(self)
	print("TreeParser: found %s player spawns" % [player_spawn_spots.size()])
	
	for _ps in player_spawn_spots:
		players.add_spawn_spot(_ps)
		
	pass # Replace with function body.

func _exit_tree():
	print("TreeParser: exits tree")
	for _ps in player_spawn_spots:
		players.remove_spawn_spot(_ps)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# This function traverses all children of a node recursively
# and applies a callback function to each of them.
func traverse(node):
	# Call the callback function on the current node
	process_node(node)
	
	# Recursively call this function on all children
	for child in node.get_children():
		traverse(child)
		
func process_node(node: Object):
	print("TreePraser: processing node: %s, type: %s" % [node.name, node.get_class()])
	var props = tools.parse_properties(node.name)
	print(props)
	
	if node is RigidBody3D:
		world.add_rigidbody(node)
	
	if "spawn" in props:
		process_spawn_node(node, props)
	
	if "mass" in props:
		if node.get_parent() is RigidBody3D:
			print("TreeParser: setting %s rigid body mass to %s" % [node.name, props["mass"]])
			node.get_parent().mass = float(props["mass"])
	

func process_spawn_node(node, props):
	print("TreeParser: processing spawn-node %s" % node.name)
	
	match props["spawn"]:
		"player":
			player_spawn_spots.append(node)
			pass
