extends Node3D

class_name RaySet

@export var rays: Array[RayCast3D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_find_rays(self)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func is_any_colliding()->bool:
	for ray in rays:
		if ray.is_colliding():
			return true
	return false
	
func is_all_colliding()->bool:
	for ray in rays:
		if not ray.is_colliding():
			return false
	return true
	
func get_first_colliding() -> RayCast3D:
	for ray in rays:
		if ray.is_colliding():
			return ray
	return null

func _find_rays(node):
	# Call the callback function on the current node
	if node is RayCast3D:
		rays.append(node)

	# Recursively call this function on all children
	for child in node.get_children():
		_find_rays(child)
