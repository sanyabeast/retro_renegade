extends Node

class_name PlayerManager

var spawn_spots: Array[Node3D] = []
var current: Node3D = null

func add_spawn_spot(node: Node3D):
	dev.logd("PlayerManager", "adding new spawn spot: %s" % node.name)
	spawn_spots.append(node)

func remove_spawn_spot(node: Node3D):
	dev.logd("PlayerManager", "removing new spawn spot: %s" % node.name)
	var index = spawn_spots.find(node)
	if index > -1:
		spawn_spots.remove_at(index)
	
func respawn_player():
	if current != null:
		dev.logd("PlayerManager", "freeing current player")
		current.queue_free()
		
	if world.level == null:
		dev.logd("PlayerManager", "FAILED to respawn player: no world.level set")
		return
	if world.level.settings.player_default_class == null:
		dev.logd("PlayerManager", "FAILED to respawn player: no world.level.default_player set")
		return
	if spawn_spots.size() == 0:
		dev.logd("PlayerManager", "FAILED to respawn player: no spawn_spots")
		return	
	
	var _spot: Node3D = tools.get_random_element_from_array(spawn_spots)	
	var player = tools.spawn_object_with_transform(world.level.settings.player_default_class, _spot.global_transform, world.level)
	current = player
	dev.logd("PlayerManager", "successfully respawned at %s" % _spot.name)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
