extends Node3D

@export var swing_speed: float = 2.0
@export var swing_angle: float = 5.0

var time_elapsed: float = 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	
	var rotation_z = sin(time_elapsed * swing_speed) * deg_to_rad(swing_angle)
	rotation.z = rotation_z
