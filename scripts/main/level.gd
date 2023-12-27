extends Node3D

class_name GameLevel

@export var settings: RGameLevel

var bounds_start: Vector3
var bounds_stop: Vector3
var bounds_size: Vector3

var _bounds_root: Area3D
var _bounds_collision: CollisionShape3D

# signals
signal on_character_exited(character: GameCharacter)
signal on_character_entered(character: GameCharacter)
signal on_rigidbody_exited(character: GameCharacter)
signal on_rigidbody_entered(character: GameCharacter)

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_tree(self)
	_setup_bounds()
	
	_bounds_root.connect("body_entered", _handle_body_entered)
	_bounds_root.connect("body_exited", _handle_body_exited)
	
	world.set_level(self)
	pass # Replace with function body.

func _exit_tree():
	world.unset_level(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _setup_tree(node):
	# Call the callback function on the current node
	
	if _bounds_root == null and node is Area3D and node.name == "Bounds":
		_bounds_root = node
		
	if _bounds_collision == null and node is CollisionShape3D and node.name == "BoundaryBox":
		_bounds_collision = node	
		
	if _bounds_root != null and _bounds_collision != null:
		return
	
	# Recursively call this function on all children
	for child in node.get_children():
		_setup_tree(child)

func _setup_bounds():
	# assertions
	assert(_bounds_root != null, "Level _bounds_root must be set up")
	assert(_bounds_root.scale == Vector3.ONE, "Level _bounds_root scale must be [1, 1, 1]")
	assert(_bounds_root.rotation == Vector3.ZERO, "Level _bounds_root rotaiton must be [0, 0, 0]")
	assert(_bounds_collision != null, "Level _bounds_collision must be set up")
	#assert(_bounds_collision.scale == Vector3.ONE, "Level _bounds_collision scale must be [1, 1, 1]")
	assert(_bounds_collision.rotation == Vector3.ZERO, "Level _bounds_collision rotaiton must be [0, 0, 0], found %s" % _bounds_collision.rotation)
	assert(_bounds_collision.shape is BoxShape3D, "Level _bounds_collision shape must be BoxShape3D, found %s" % _bounds_collision.shape)
	# ---
	
	var box: BoxShape3D = _bounds_collision.shape
	
	bounds_start = _bounds_collision.global_position - box.size / 2
	bounds_stop = _bounds_collision.global_position + box.size / 2
	bounds_size = box.size

func direction_to_bounds(node: Node3D):
	var dir = Vector3.ZERO
	
	if node.global_position.y <= bounds_start.y:
		dir += Vector3.UP
	if node.global_position.y >= bounds_stop.y:
		dir += Vector3.DOWN
	if node.global_position.x <= bounds_start.x:
		dir += Vector3.RIGHT
	if node.global_position.x >= bounds_stop.x:
		dir += Vector3.LEFT
	if node.global_position.z <= bounds_start.z:
		dir += Vector3.BACK
	if node.global_position.z >= bounds_stop.z:
		dir += Vector3.FORWARD	
		
	return dir.normalized()
		
func distance_to_bounds(node: Node3D)-> float:
	var direction: Vector3 = direction_to_bounds(node)
	var distance = 0
	
	if direction.y > 0:
		distance += bounds_start.y - node.global_position.y
	if direction.y < 0:
		distance += node.global_position.y - bounds_stop.y
	if direction.x > 0:
		distance += bounds_start.x - node.global_position.x
	if direction.x < 0:
		distance += node.global_position.x - bounds_stop.x
	if direction.z > 0:
		distance += bounds_start.z - node.global_position.z
	if direction.z < 0:
		distance += node.global_position.z - bounds_stop.z
			
	return distance
				
func _handle_body_entered(node):
	if node is GameCharacter:
		on_character_entered.emit(node)
	if node is RigidBody3D:
		on_rigidbody_entered.emit(node)

func _handle_body_exited(node):
	if node is GameCharacter:
		on_character_exited.emit(node)
	if node is RigidBody3D:
		on_rigidbody_exited.emit(node)
