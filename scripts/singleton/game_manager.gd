extends Node

class_name GameManager


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if world.level != null:
		if players.current == null and world.level.player_spawn_auto and world.level.player_retry_current <= world.level.player_retry_max:
			players.respawn_player()
			pass
