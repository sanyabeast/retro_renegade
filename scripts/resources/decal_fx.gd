extends Resource

class_name RDecalFX

enum ERDecalContactType {
	Direct,
	Ray,
	Sphere
}

@export var decals: Array[RDecalSettings]
@export var contact_type: ERDecalContactType = ERDecalContactType.Direct
@export var lifetime: float = 5

@export_subgroup("Extras")
@export var contact_trace_distance: float = 0.5
