extends Node

class_name GameCharacterBodyAnimationScript

var body_controller: GameCharacterBodyController
var animation_tree: AnimationTree
var animation_player: AnimationPlayer

func initialize(_body_controller: GameCharacterBodyController):
	body_controller = _body_controller
	
	if body_controller._animation_tree != null:
		animation_tree = body_controller._animation_tree
		
	if body_controller._animation_player != null:
		animation_player = body_controller._animation_player
	
	
	var character = body_controller.character
	var phys_interaction: GameCharacterPhysicalInteractionManager = character.phys_interaction
	
	phys_interaction.on_object_grab.connect(_handle_object_grab)
	phys_interaction.on_object_drop.connect(_handle_object_drop)
	phys_interaction.on_object_throw.connect(_handle_object_throw)
		
		
	on_setup()
	pass

func on_setup():
	pass

func _handle_object_grab(object: Node3D):
	pass
	
func _handle_object_drop(object: Node3D):
	pass
	
func _handle_object_throw(object: Node3D):
	pass
