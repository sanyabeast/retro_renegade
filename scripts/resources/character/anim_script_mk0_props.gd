extends Resource

class_name RAnimScriptMK0Props

@export var move_animation_speed_scale: float = 1.5
@export var body_twist_max_angle: float = 70
@export var body_bend_max_angle: float = 15
@export var body_tilt_max_angle: float = 10

@export var body_crouched_twist_max_angle: float = 25
@export var body_crouched_bend_angle: float = 15
@export var body_crouched_tilt_max_angle: float = 5

@export_subgroup("Animation Style")
@export var walk_style: float = 0
@export var run_style: float = 0
@export var idle_style: float = 0
@export var crouch_idle_style: float = 0
@export var fall_style: float = 0

@export_subgroup("Transitions and Blending")
@export var vertical_blend_transition_speed: float = 4
@export var horizontal_blend_transition_speed: float = 8

@export_subgroup("Extras")
@export var force_looping_for_animations: Array[String] = [
	"Idle_A",
	"Idle_B",
	"Idle_C",
	"Walk_A",
	"Walk_B",
	"Walk_C",
	"Run_A",
	"Run_B",
	"Run_C",
	"Crouch_Idle_A",
	"Crouch_Idle_B",
	"Fall_A",
	"Fall_B"
]
