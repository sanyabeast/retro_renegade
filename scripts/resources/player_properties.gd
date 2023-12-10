extends Resource

class_name RPlayerProperties 


@export_subgroup("Abilities")
@export var allow_climbing: bool = true
@export var allow_sprint: bool = true
@export var allow_jump: bool = true
@export var allow_dash: bool = true

@export_subgroup("Ability Parameters")
@export var climbing_speed: float = 16
@export var jump_speed: float = 12
@export var flip_sprint_walk: bool = false
@export var dash_speed: float = 12
@export var dash_duration: float = 1

@export var walk_speed_min: float = 4
@export var walk_speed_max: float = 6
@export var walk_acceleration: float = 4
@export var sprint_acceleration: float = 4
@export var sprint_speed_max: float = 12

@export var climbing_max_distance: float = 4
@export var crouching_walk_penalty: float = 0.75
@export var crouching_jump_penalty: float = 0.75
@export var vertical_velocity_min: float = -64
@export var vertical_velocity_max: float = 64

@export_subgroup("Physical Interaction")
@export var hand_manipulation_pull_force: float = 1000
@export var hand_manipulation_close_grip_distance: float = 0.2
@export var hand_manipulation_throw_power: float = 16
@export var hand_manipulation_throw_ballistics: float = 0.25
@export var hand_manipulation_drop_power: float = 2
@export var hand_manipulation_max_weight: float = 50
