extends Node

class_name Tools

enum ENodeType {
	MeshInstance,
	RigidBody,
	CollisionShape
}

# Recursive function to get all descendants with a specific substring in their names
func get_descendants_with_substring(root: Node, substring: String, matching_nodes: Array) -> Array:
	for child in root.get_children():
		if substring in child.name:
			matching_nodes.append(child)
		get_descendants_with_substring(child, substring, matching_nodes)
	return matching_nodes

func get_first_descendant_with_substring(root: Node, substring: String) -> Node:
	for child in root.get_children():
		if substring in child.name:
			return child
	return null

func spawn_object(template: PackedScene, parent: Node) -> Node:
	# Instance the scene
	var instance = template.instantiate()

	# Add the instance to the current scene tree
	if parent == null:
		parent = get_scene()
	
	instance.global_position = Vector3(0, 0, 0)
	parent.add_child(instance)

	# Optional: Set the position or other properties
	
	return instance
	
func spawn_object_with_transform(template: PackedScene, transform: Transform3D, parent: Node) -> Node:
	# Instance the scene
	var instance: Node = template.instantiate()

	if parent == null:
		parent = get_scene()
	
	instance.global_transform = transform
	parent.add_child(instance)

	# Optional: Set the position or other properties
	
	return instance
	
func spawn_object_at_position(template: PackedScene, position: Vector3, parent: Node) -> Node:
	# Instance the scene
	var instance: Node = template.instantiate()

	if parent == null:
		parent = get_scene()
		
	instance.global_position = position
	parent.add_child(instance)

	# Optional: Set the position or other properties
	
	return instance
	
func spawn_object_with_position_and_scale(template: PackedScene, position: Vector3, scale: Vector3, parent: Node) -> Node:
	# Instance the scene
	var instance: Node = template.instantiate()

	if parent == null:
		parent = get_scene()
		
		
	instance.global_position = position
	instance.scale = scale
	parent.add_child(instance)

	# Optional: Set the position or other properties
	
	return instance

func parse_properties(input_str: String) -> Dictionary:
	var properties = {}
	var substrings = input_str.split(" ")

	for substring in substrings:
		if substring.begins_with("-"):
			var pair = substring.substr(1).split("=")
			var name = pair[0]
			var value = null

			if pair.size() > 1:
				value = pair[1]

			properties[name] = value

	return properties

func lerp_transform_rotation(transform: Transform3D, target_transform: Transform3D, alpha: float = 0.5)->Basis:
	var a = Quaternion(transform.basis)
	var b = Quaternion(target_transform.basis)
	# Interpolate using spherical-linear interpolation (SLERP).
	var c = a.slerp(b, alpha) # find halfway point between a and b
	# Apply back
	return Basis(c)

func spawn_object_and_replace(packed_scene: PackedScene, existing_object: Node) -> Node:
	# Check if the arguments are valid
	if packed_scene == null or existing_object == null:
		dev.logd("Tools", "Invalid arguments passed to the function.")
		return

	# Instantiate the new object from the PackedScene
	var new_object = packed_scene.instantiate()

	# Assign transformations from the existing object to the new one
	new_object.transform = existing_object.transform

	# Add the new object to the same parent as the existing object
	if existing_object.get_parent():
		existing_object.get_parent().add_child(new_object)

	# Optionally, if you want to keep the same tree order, you can use this:
	# var index = existing_object.get_index()
	# existing_object.get_parent().add_child_below_node(existing_object, new_object)
	# existing_object.get_parent().move_child(new_object, index)

	# Queue the existing object for deletion
	existing_object.queue_free()
	return new_object

func get_active_camera():
	return get_viewport().get_camera_3d()

func get_scene() -> Node3D:
	return get_tree().current_scene

func get_random_element_from_array(arr: Array):
	if arr.size() == 0:
		return null
	var random_index = randi() % arr.size()
	return arr[random_index]

func get_random_key_from_dict(dict: Dictionary):
	if dict.is_empty():
		return null
	var keys = dict.keys()
	var random_index = randi() % keys.size()
	return keys[random_index]

func get_random_value_from_dict(dict: Dictionary):
	if dict.is_empty():
		return null
	var values = dict.values()
	var random_index = randi() % values.size()
	return values[random_index]

func random_bool() -> bool:
	return randi() % 2 == 0
	
func random_bool2(ratio: float) -> bool:
	return randf() < ratio

func change_material(node: MeshInstance3D, index: int, new_material: Material):
	if node and node is MeshInstance3D:
		node.set_surface_override_material(index, new_material)

func get_global_forward_vector(node: Node3D) -> Vector3:
	return -node.global_transform.basis.z.normalized()

func reload_scene():
	var current_scene = get_tree().current_scene
	get_tree().reload_current_scene()

func load_scene(scene_path: String):
	var tree: SceneTree = get_tree()
	tree.change_scene_to_file(scene_path)
	
func load_scene_packed(packed_scene: PackedScene):
	dev.logd("Tools", "prepare to load scene: %s" % packed_scene)
	var tree: SceneTree = get_tree()
	var result = tree.change_scene_to_packed(packed_scene)
	dev.logd("Tools", "LOADING PACKED SCENE, RESULT: %s" % result)

func get_forward_vector(node: Node3D):
	return -node.global_transform.basis.z

func lerp_inverse(current: float, from: float, to: float)-> float:
	if to - from == 0:
		return 0 # Avoid division by zero

	var alpha = (current - from) / (to - from)
	return clamp(alpha, 0.0, 1.0) # Clamping to ensure the result is between 0 and 1

func v3_to_v2(v3: Vector3)->Vector2:
	return Vector2(v3.x, v3.y)

func random_float(min_value: float, max_value: float) -> float:
	return randf_range(min_value, max_value)

func progress_to_percentage(p: float) -> String:
	return "%s%%" % int(p * 100)

# SEARCHING BY NODE TYPE:
func _test_node_type(node, node_type: ENodeType):
	var test: bool = false
	match node_type:
		ENodeType.RigidBody:
			test = node is RigidBody3D
		ENodeType.MeshInstance:
			test = node is MeshInstance3D
		ENodeType.CollisionShape:
			test = node is CollisionShape3D
		_:
			test = node is Node3D
		
	return test

func find_nodes_of_type_recursively(node: Node3D, node_type: ENodeType, result)->Array[Node3D]:
	if result == null:
		result = [] as Array[Node3D]
	
	if  _test_node_type(node, node_type):
		result.add(node)
		
	# Recursively call this function on all children
	for child in node.get_children():
		find_nodes_of_type_recursively(child, node_type, result)
		
	return result as Array[Node3D]


func find_first_node_of_type_recursively(node: Node3D, node_type: ENodeType):
	if _test_node_type(node, node_type):
		return node
	# Recursively call this function on all children
	for child in node.get_children():
		var result = find_first_node_of_type_recursively(child, node_type)
		if result: 
			return result
		
static func load_config() -> RGameConfig:
	return load("res://resources/config.tres");

# DATA CONTAINERS
class DataContainer:
	var data: Dictionary
	func _init(_data):
		data = _data
	func update(key, value):
		data[key] = value
	func unset(key):
		data.erase(key)

class TimerGateManager:
	var _timer_gate_data = {}

	func check(id: String, timeout: float) -> bool:
		var current_time = Time.get_ticks_msec() / 1000.0
		if not _timer_gate_data.has(id) or current_time - _timer_gate_data[id] >= timeout:
			_timer_gate_data[id] = current_time
			return true
		return false

var timer_gate: TimerGateManager = TimerGateManager.new()
