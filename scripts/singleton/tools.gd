extends Node

class_name Tools


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


func spawn_object_and_replace(packed_scene: PackedScene, existing_object: Node) -> Node:
	# Check if the arguments are valid
	if packed_scene == null or existing_object == null:
		print("Invalid arguments passed to the function.")
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
	print("prepare to load scene: %s" % packed_scene)
	var tree: SceneTree = get_tree()
	var result = tree.change_scene_to_packed(packed_scene)
	print("LOADING PACKED SCENE, RESULT: %s" % result)

func get_forward_vector(node: Node3D):
	return -node.global_transform.basis.z

func lerp_inverse(current: float, from: float, to: float)-> float:
	if to - from == 0:
		return 0 # Avoid division by zero

	var alpha = (current - from) / (to - from)
	return clamp(alpha, 0.0, 1.0) # Clamping to ensure the result is between 0 and 1

func random_float(min_value: float, max_value: float) -> float:
	return randf_range(min_value, max_value)

# POSITIONAL SOUNDS
var _sound_players: Array[AudioStreamPlayer3D] = []

func _check_sound_players():
	print("checking snds")
	var active_sounds: Array[AudioStreamPlayer3D] = []
	var finished_sounds: Array[AudioStreamPlayer3D] = []
	
	for item in _sound_players:
		if item == null:
			continue
		if item.finished:
			finished_sounds.append(item)
		else:
			active_sounds.append(item)
	
	for _sound in finished_sounds:
		_sound.queue_free()		
			
	_sound_players = active_sounds

func play_sound_at_position(audio_fx: RAudioFX, position: Vector3, override_volume = null, override_pitch = null):
	if audio_fx == null:
		print("Tools.play_sound_at_position: failed - audio_fx is null")
		return
		
	var audio_player = AudioStreamPlayer3D.new()
	
	_sound_players.append(audio_player)
	get_scene().add_child(audio_player)  # Add it to the scene
	
	# Set the position
	audio_player.global_transform.origin = position
	# Optional: Automatically remove the node after playback
	audio_player.connect("finished", _check_sound_players)
	play_audio_fx(audio_player, audio_fx, override_volume, override_pitch)
	
	dev.print_screen("sounds_count", "sounds: %s" % _sound_players.size())

func play_audio_fx(audio_player: AudioStreamPlayer3D, audio_fx: RAudioFX, override_volume = null, override_pitch = null):
	# Load the audio file
	
	if audio_fx.clips == null or audio_fx.clips.size() == 0:
		print("Tools.play_audio_fx: unable to play: no clips at audiofx: %s" % audio_fx.resource_name)
		return
	
	audio_player.stream = get_random_element_from_array(audio_fx.clips)
	audio_player.volume_db = lerpf(-64, 0, sqrt(randf_range(audio_fx.volume_min, audio_fx.volume_max)))
	audio_player.max_db = lerpf(-64, 0, sqrt(randf_range(audio_fx.volume_limit_min, audio_fx.volume_limit_max)))
	audio_player.pitch_scale = randf_range(audio_fx.pitch_min, audio_fx.pitch_max)
	audio_player.max_distance = audio_fx.max_distance
	audio_player.attenuation_model = audio_fx.attenuation_mode
	audio_player.panning_strength = audio_fx.panning_strength
	
	if override_volume is float: 
		audio_player.max_db = override_volume
		
	if override_pitch is float: 
		audio_player.pitch_scale = override_pitch

	# Play the sound
	audio_player.play()


var _timer_gate_date = {}

class TimerGateManager:
	var _timer_gate_date = {}

	func check(id: String, timeout: float) -> bool:
		var current_time = Time.get_ticks_msec() / 1000.0
		if not _timer_gate_date.has(id) or current_time - _timer_gate_date[id] >= timeout:
			_timer_gate_date[id] = current_time
			return true
		return false

var timer_gate: TimerGateManager = TimerGateManager.new()
