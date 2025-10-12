class_name Grabbable

extends RigidBody3D

var held = false

func on_pickup():
	held = true
	# Disable all collisions
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = true
	# POSITION IN FRONT OF CAMERA 
	position = Vector3(0.3, -0.2, -0.5)  
	rotation_degrees = Vector3(0, 0, 0)
	scale = Vector3(1, 1, 1) 
	freeze = true

func on_dropped():
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = false
	held = false
	rotation_degrees = Vector3(0, 0, 0)
	freeze = false

func _physics_process(_delta: float) -> void:
	if held:
		position = Vector3(0.3, -0.2, -0.5)  
		rotation_degrees = Vector3(0, 0, 0)
		scale = Vector3(1, 1, 1) 
