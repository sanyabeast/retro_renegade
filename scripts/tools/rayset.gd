extends Node3D

class_name RaySet

## RayCast3D children will be added automatically
@export var rays: Array[RayCast3D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_find_rays(self)
	pass # Replace with function body.

func add_exception(node: CollisionObject3D):
	for r in rays:
		r.add_exception(node)
		
func remove_exception(node: CollisionObject3D):
	for r in rays:
		r.remove_exception(node)		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for r in rays:
		var color = Color.LIGHT_CORAL if r.is_colliding() else Color.GREEN_YELLOW
		dev.draw_gizmo_ray(self, 'ray%s' % r.name, r.global_position, r.to_global(r.target_position), color)
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
	
func get_first_colliding_ray() -> RayCast3D:
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
