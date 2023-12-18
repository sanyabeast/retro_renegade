extends Resource

class_name RGameLevel

@export var name: String = "Some Game Level"
@export var player_default_class: PackedScene
@export var player_spawn_auto: bool = true
@export var player_retry_max: int = 3
@export var default_character_camera_mode: GameCharacterCameraRig.EGameCharacterCameraMode = GameCharacterCameraRig.EGameCharacterCameraMode.FirstPerson

