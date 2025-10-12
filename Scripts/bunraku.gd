class_name Bunraku

extends AnimatableBody3D

@export var anger_headshake_factor: float
@export var anger_bodyshake_factor: float
@export_range(0,1) var anger_level: float
@onready var body_sprite: Sprite3D = $Body
@onready var head_sprite: Sprite3D = $Body/Head

var mat: StandardMaterial3D

func _ready() -> void:
	mat = head_sprite.material_override as StandardMaterial3D
	
func _physics_process(_delta: float) -> void:
	body_sprite.offset = Vector2.ZERO
	head_sprite.rotation.z = 0
	mat.emission_energy_multiplier = 0
	
	if anger_level > 0:
		var _x = randf_range(-anger_level, anger_level)
		head_sprite.rotation.z = -_x * anger_headshake_factor
		body_sprite.offset = Vector2(_x, 0) * anger_bodyshake_factor
		mat.emission_energy_multiplier = anger_level
