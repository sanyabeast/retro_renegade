extends Node

class_name GameManager

var player_retry_current: int = 0
var speed: float = 1
var time: float = 0
var _target_speed: float = 0
var _speed_change_transition: float = 8

@onready var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()

var paused: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	resume()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _timer_gate.check("tasks", 0.25):
		if world.level != null:
			if players.current == null and world.level.settings.player_spawn_auto and player_retry_current <= world.level.settings.player_retry_max:
				players.respawn_player()
				pass
		
	if Input.is_action_just_pressed("pause"):
		if not hud.cancel_action_locked:
			if paused:
				resume()
			else:
				pause()
				
	time += delta * speed
	speed = move_toward(speed, _target_speed, _speed_change_transition * delta)

func resume():
	paused = false
	hud.state.replace(app.config.hud_default_state_in_game)
	_target_speed = 1
	
func pause():
	paused = true
	hud.state.replace(app.config.hud_default_state_paused)
	_target_speed = 0
