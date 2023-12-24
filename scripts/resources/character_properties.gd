extends Resource

class_name RCharacterProperties 

@export_subgroup("Abilities")
@export var allow_climbing: bool = true
@export var allow_sprint: bool = true
@export var allow_jump: bool = true
@export var allow_dash: bool = true

@export_subgroup("Walk")
@export var walk_speed_min: float = 3
@export var walk_speed_max: float = 6
@export var walk_acceleration: float = 4
@export var back_walk_speed_min: float = 1
@export var back_walk_speed_max: float = 3

@export_subgroup("Sprint")
@export var sprint_acceleration: float = 4
@export var sprint_speed_max: float = 12
@export var back_sprint_speed_max: float = 6

@export_subgroup("Crouch")
@export var crouching_walk_penalty: float = 0.75

@export_subgroup("Jump")
@export var jump_speed: float = 12
@export var jump_max_charge_duration: float = 0.2

@export_subgroup("Climb")
@export var climbing_speed: float = 16
@export var climbing_max_distance: float = 4

@export_subgroup("Physical Interaction")
@export var hand_manipulation_pull_force: float = 1000
@export var hand_manipulation_close_grip_distance: float = 0.2
@export var hand_manipulation_throw_power: float = 16
@export var hand_manipulation_throw_ballistics: float = 0.25
@export var hand_manipulation_drop_power: float = 2
@export var hand_manipulation_max_weight: float = 50

@export_subgroup("Extras")
@export var gravity_multiplier: float = 3
@export var vertical_velocity_min: float = -64
@export var vertical_velocity_max: float = 64

@export var flip_sprint_walk: bool = false
@export var dash_speed: float = 12
@export var dash_duration: float = 1
