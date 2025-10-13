extends StaticBody3D

@export var gear_target_position: Vector3 = Vector3(-2.3, 0.015, -1.15)  
@export var gear_rotation: Vector3 = Vector3(0, 90, 0)  
var has_gear: bool = false


func can_pickup() -> bool:
	return has_gear

func on_pickup():
	if has_gear:
		# Find the gear
		var gears = get_tree().get_nodes_in_group("pickupable")
		for node in gears:
			if node.global_position.distance_to(gear_target_position) < 0.5:
				if node.is_in_socket:
					node.is_in_socket = false
					node.freeze = false
					has_gear = false
					# Let player pick it up
					if node.can_pickup():
						Player.instance.pick_up_object(node)
					return
	
	# When clicked with a gear held place it in the socket
	if Player.instance.held_object and Player.instance.held_object is Grabbable:
		var gear = Player.instance.held_object
		
		# Remove from player hand
		Player.instance.held_object = null
		Player.instance.get_node("Camera3D").remove_child(gear)
		
		get_tree().root.get_child(0).add_child(gear)
		
		print("Placing gear at: ", gear_target_position)
		print("With rotation: ", gear_rotation)
		#teleport to target coordinates 
		gear.global_position = gear_target_position
		
		for child in gear.get_children():
			if child is CollisionShape3D:
				child.disabled = false
		gear.held = false
		gear.is_in_socket = true 
		
		# Set  rotation BEFORE freezing
		gear.rotation_degrees = gear_rotation
		gear.global_rotation_degrees = gear_rotation
		
		gear.freeze = true
		gear.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		
		has_gear = true
