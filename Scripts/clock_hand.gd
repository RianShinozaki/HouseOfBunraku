extends Node3D


@export var seconds_per_rotation: float = 60.0

func _process(delta: float) -> void:
	var rotation_speed = (2 * PI) / seconds_per_rotation
	
	# Rotate clockwise 
	rotation.z -= rotation_speed * delta
