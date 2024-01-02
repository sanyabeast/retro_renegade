extends Resource

class_name RNPCProps
	
@export_subgroup("Navigation")
@export var move_direction_change_speed_min: float = 4
@export var move_direction_change_speed_max: float = 48

@export_subgroup("Body")
@export var body_direction_change_speed_min: float = 720
@export var body_direction_change_speed_max: float = 1440
@export var look_direction_change_speed: float = 360
