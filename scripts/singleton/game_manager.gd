extends Node

class_name GameManager

var player_retry_current: int = 0
@onready var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _timer_gate.check("tasks", 0.25):
		if world.level != null:
			if players.current == null and world.level.settings.player_spawn_auto and player_retry_current <= world.level.settings.player_retry_max:
				players.respawn_player()
				pass
					
		
