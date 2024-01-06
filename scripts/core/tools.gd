extends Node

class_name Tools

enum ENodeType {
	MeshInstance,
	RigidBody,
	CollisionShape
}

func get_time()->float:
	return game.time
	#return Time.get_ticks_msec() / 1000.0

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

func spawn_object_with_position_and_roation(template: PackedScene, position: Vector3, rotation_degrees: Vector3, parent: Node) -> Node:
	# Instance the scene
	var instance: Node = template.instantiate()

	if parent == null:
		parent = get_scene()
		
		
	instance.global_position = position
	instance.rotation_degrees = rotation_degrees
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
		
func lerpt(from: float, to: float, weight: float, threshold: float = 0.1):
	if abs(to - from) < threshold:
		return to
	else:
		return lerpf(from, to, weight)

func move_toward_deg(from_angle: float, to_angle: float, delta: float)->float:
	return rad_to_deg(rotate_toward(deg_to_rad(from_angle + 180), deg_to_rad(to_angle + 180), deg_to_rad(delta))) - 180

func rotation_degrees_y_from_direction(direction: Vector3)->float:
	return rad_to_deg(atan2(direction.x, direction.z))
	
# returns the difference (in degrees) between angle1 and angle 2
# the given angles must be in the range [0, 360)
# the returned value is in the range (-180, 180]
func angle_difference(angle1, angle2):
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))
		
static func load_config() -> RGameConfig:
	return load("res://resources/config.tres");


func polarity(val: float)->float:
		return -1 if val < 0 else 1

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
		var current_time = tools.get_time()
		if not _timer_gate_data.has(id) or current_time - _timer_gate_data[id] >= timeout:
			_timer_gate_data[id] = current_time
			return true
		return false
		
			
var timer_gate: TimerGateManager = TimerGateManager.new()

# Cooldown Manager
class CooldownManager:
	var _cooldowns_data = {}
	
	class CooldownItem:
		var id: String
		var started_at: float = 0
		var duration: float = 0
		func _init(_id: String, _duration: float):
			id = _id
			start(_duration)
		func start(_duration: float):
			duration = _duration
			started_at = tools.get_time()
		func ready()->bool:
			return progress() >= 1
		func progress()->float:
			return clampf((tools.get_time() - started_at) / duration, 0.0, 1.0)
		func estimated()->float:
			return clampf(duration - (tools.get_time() - started_at), 0, duration)
			
	
	func start(id: String, duration: float):
		if not _cooldowns_data.has(id):
			_cooldowns_data[id] = CooldownItem.new(id, duration)
		else:
			_cooldowns_data[id].start(duration)
	func exists(id: String):
		return _cooldowns_data.has(id)
	func stop(id: String):
		if _cooldowns_data.has(id):
			_cooldowns_data.erase(id)
	func progress(id: String)->float:
		if _cooldowns_data.has(id):
			return _cooldowns_data[id].progress()
		else:
			return 0
	func estimated(id: String)->float:
		if _cooldowns_data.has(id):
			return _cooldowns_data[id].estimated()
		else:
			return 0
	func ready(id: String)->bool:
		if _cooldowns_data.has(id):
			return _cooldowns_data[id].ready()
		else:
			return false
	func reset():
		_cooldowns_data = {}

# JobScheduler
class TaskPlanner:
	static var _schedule_task_index_counter: int = 0
	
	class Task:
		var owner: Node3D
		var id: String
		var duration: float
		var start_callback
		var finish_callback
		var started_at: float = -1
		
		func _init(_owner: Node3D, _id: String, _duration: float, _start_callback, _finish_callback):
			owner = _owner
			id = _id
			duration = _duration
			start_callback = _start_callback
			finish_callback = _finish_callback
		func is_expired()->bool:
			if started_at < 0:
				return false
			else:
				return (tools.get_time() - started_at) > duration
		func start():
			started_at = tools.get_time()
			
			if start_callback != null:
				start_callback.call()
		func finish():
			if finish_callback != null:
				finish_callback.call()
		
		func is_valid()->bool:
			return owner != null
	
	# TaskPlanner props
	var list: Array[Task] = []
	var schedule_list = {}
	var current: Task
	
	# TaskPlanner methods
	func update():
		if current == null:
			if list.size() > 0:
				current = list.pop_back()
				if current.is_valid():
					print("[TaskPlanner] task STARTED %s %s" % [current.owner.name, current.id])
					current.start()
				else:
					current = null
		else:
			if current.is_expired():
				if current.is_valid():
					print("[TaskPlanner] task FINISHED %s %s" % [current.owner.name, current.id])
					current.finish()
					
				current = null	
				
		for key in schedule_list.keys():
			var task: Task = schedule_list[key]
			if task.is_expired():
				if task.is_valid():
					print("[TaskPlanner] scheduled task FINISHED %s %s" % [task.owner.name, task.id])
					task.finish()
				schedule_list.erase(key)
				
	func queue(owner: Node3D, id: String, duration: float, start_callback, finish_callback):
		list.push_front(TaskPlanner.Task.new(
			owner,
			id,
			duration,
			start_callback,
			finish_callback
		))
		print("[TaskPlanner] task ADDED to queue %s %s" % [owner.name, id])
		pass
	
	func stack(owner: Node3D, id: String, duration: float, start_callback, finish_callback):
		list.push_back(TaskPlanner.Task.new(
			owner,
			id,
			duration,
			start_callback,
			finish_callback,
		))
		print("[TaskPlanner] task ADDED to stack %s %s" % [owner.name, id])
		pass
		
	func schedule(owner: Node3D, id: String, timeout: float, finish_callback):
		var task: Task = Task.new(owner, id, timeout, null, finish_callback)
		TaskPlanner._schedule_task_index_counter += 1	
		schedule_list[TaskPlanner._schedule_task_index_counter] = task
		task.start()
		
	func stack_replace(owner: Node3D, id: String, duration: float, start_callback, finish_callback):
		cancel(owner, id)
		stack(owner, id, duration, start_callback, finish_callback)
	
	func queue_replace(owner: Node3D, id: String, duration: float, start_callback, finish_callback):
		cancel(owner, id)
		queue(owner, id, duration, start_callback, finish_callback)
	
	func schedule_replace(owner: Node3D, id: String, timeout: float, finish_callback):
		cancel(owner, id)
		schedule(owner, id, timeout, finish_callback)
	
	
	func cancel(owner: Node3D, id):
		if current != null and current.owner == owner:
			if id == null or id == current.id:
				current = null
		
		var new_list: Array[Task] = []
		
		for task in list:
			if task.owner != owner:
				if id != null or id != task.id:
					new_list.append(task)
		
		for key in schedule_list.keys():
			var task: Task = schedule_list[key]
			if task.owner == owner:
				if id == null or id == task.id:
					schedule_list.erase(key)
		
		list = new_list
	
	func clear(finish_current: bool = true):
		list = []
		
		if finish_current and current != null:
			current.finish()
			
		current = null
