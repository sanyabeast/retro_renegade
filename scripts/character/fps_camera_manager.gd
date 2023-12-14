extends Node3D

class_name FPSCameraManager

@onready var camera: Camera3D = $Camera3D

@onready var walk_shaking_angle: float = 0.3
@onready var walk_shaking_elevation: float = 0.03
@onready var walk_shaking_speed: float = 1

var dash_camera_slope: float = 15

func get_camera_basis() -> Basis:
	return camera.global_transform.basis

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#camera.rotation.z = deg_to_rad(sin((player.travelled) * walk_shaking_speed) * walk_shaking_angle)
	#camera.rotation.y = deg_to_rad(sin((player.travelled) * walk_shaking_speed) * walk_shaking_angle)
	#camera.position.y = sin((player.travelled) * walk_shaking_speed * 2) * walk_shaking_elevation
	
	pass
