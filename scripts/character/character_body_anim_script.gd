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
		
	on_setup()
	pass

func on_setup():
	pass
