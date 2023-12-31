extends Resource

class_name RNPCProps
	
@export_subgroup("Navigation")
@export var move_direction_change_speed_min: float = 1
@export var move_direction_change_speed_max: float = 8

@export_subgroup("Body")
@export var body_direction_change_speed_min: float = 180
@export var body_direction_change_speed_max: float = 360
@export var look_direction_change_speed: float = 360
