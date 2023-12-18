extends CollisionShape3D

class_name GameCharacterBody

@export_subgroup("Pin Points")
@export var head_pin_point: Node3D
@export var eyes_pin_point: Node3D
@export var hand_pin_point: Node3D
@export var chest_pin_point: Node3D

var character: GameCharacter
var _animation_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_tree(self)
	pass # Replace with function body.

func _setup_tree(node):
	if node is AnimationPlayer:
		_animation_player = node
		
	for child in node.get_children():
		_setup_tree(child)

func _process(delta):
	_update_body_state(delta)
	pass

func commit_landing(impact_power: float = 0):
	pass

	
func _update_body_state(delta):
	pass
	
