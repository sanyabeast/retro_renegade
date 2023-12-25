extends Node3D

class_name GameLevel

@export var settings: RGameLevel
@export_subgroup("Referencies")
@export var bounds: Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_tree(self)
	assert(bounds != null, "Level bounds must be set up")
	world.set_level(self)
	pass # Replace with function body.

func _exit_tree():
	world.unset_level(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _setup_tree(node):
	# Call the callback function on the current node
	
	if bounds == null and node is Area3D and node.name == "Bounds":
		bounds = node	
		
	if bounds != null:
		return
	
	# Recursively call this function on all children
	for child in node.get_children():
		_setup_tree(child)
