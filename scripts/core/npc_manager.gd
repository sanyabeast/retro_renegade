extends Node

class_name NPCManager

var _timer_gate: tools.TimerGateManager = tools.TimerGateManager.new()
var _npc_data = {}
var force_everybody_npc: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	dev.logd("NPCManager", "ready")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not game.paused:
		for character in world.characters:
			if force_everybody_npc or players.allow_npc(character):
				_process_npc(character, delta)
			
	if tools.timer_gate.check("npc_health_task", 10):
		for key in _npc_data:
			if key == null:
				_npc_data.erase(key)
	pass

func _process_npc(character: GameCharacter, delta: float):
	character.is_npc = true
	
	if not character in _npc_data:
		_npc_data[character] = {
			"move_target": Vector3.ZERO,
			"look_target": Vector3.ZERO,
			"is_idle": true,
			"is_sprint": false,
			"is_climbing": false,
			"timer_gate": tools.TimerGateManager.new()
		}
		
	if _npc_data[character]["timer_gate"].check("switch_target_point", 1):
		var random_point = world.get_random_reachable_point()
		_npc_data[character]["move_target"] = random_point
		if players.current != null:
			random_point = world.get_random_reachable_point_in_square(players.current.global_position, 128)
			
			#random_point = players.current.global_position
			
		_npc_data[character]["move_target"] = random_point
		character.nav_agent.target_position = _npc_data[character]["move_target"]
	
	
	if _npc_data[character]["timer_gate"].check("switch_is_idle", 5):
		_npc_data[character]["is_idle"] = tools.random_bool2(0.25)
	
	
	
	_npc_data[character]["is_sprint"] = character.global_position.distance_to(character.nav_agent.target_position) > 48
	_npc_data[character]["is_climbing"]	= character.is_touching_wall()
		
	var move_direction: Vector3 = (character.nav_agent.get_next_path_position() - character.global_position).normalized()
	var look_direction: Vector3 = move_direction
	if _npc_data[character]["is_idle"]:
		move_direction *= 0
		
	move_direction = character.current_movement_direction.lerp(move_direction, 0.15)
		
		
	character.set_torch_visible(false)
	character.set_movement_direction(move_direction)	
	character.set_body_direction_target(character.global_position + move_direction)
	character.look_at_direction(character.global_position + move_direction)	
	
	if _npc_data[character]["is_sprint"]:
		character.start_sprint()
	else:
		character.stop_sprint()
	pass
	
	if _npc_data[character]["is_climbing"]:
		character.start_climb()
	else:
		character.stop_climb()
	pass
