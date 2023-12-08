extends Node3D

class_name GameLevel

@export var player_default_class: PackedScene
@export var player_spawn_auto: bool = true
@export var player_retry_max: int = 3
@export var player_retry_current: int = 0
@export var game_day_length: float = 60
@export var game_day_start_time: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	world.set_level(self)
	game.game_time = game_day_start_time
	pass # Replace with function body.

func _exit_tree():
	world.unset_level(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
