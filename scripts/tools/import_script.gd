@tool
extends EditorScenePostImport
class_name ImportScript

var app_config: RGameConfig = load("res://resources/config.tres")

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	# Change all node names to "modified_[oldnodename]"
	iterate(scene)
	return scene # Remember to return the imported scene

func iterate(node):
	if node != null:
		_process_node(node)
		
		for child in node.get_children():
			iterate(child)

func _process_node(node: Object):
	print("ImportScript", "processing node: %s" % node)
	var props = ImportScript.parse_properties(node.name)

	if node is OmniLight3D:
		node.light_energy *= app_config.imported_omnilight_energy_scale
		node.omni_range = min(node.omni_range, app_config.imported_omnilight_max_range)

	if node is SpotLight3D:
		node.light_energy *= app_config.imported_spotlight_energy_scale
		node.spot_range = min(node.spot_range, app_config.imported_spotlight_max_range)

	if node is RigidBody3D:
		if "mass" in props:
			node.mass = props["mass"]
	
	if node is Node3D:
		if "player_spawn" in props:
			node.add_to_group("player-spawn")
			
static func parse_properties(input_str: String) -> Dictionary:
	input_str = remove_dot_xxx(input_str)
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

static func remove_dot_xxx(s: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\_\\d{3}$")  # The regex pattern to match .xxx where xxx are digits
	var result = regex.sub(s, "", true)
	return result
