class_name KeySocket

extends StaticBody3D

var has_key: bool = false
var key_object = null

func _ready():
	add_to_group("Interactable")
	print("KeySocket ready at: ", global_position)

func can_interact() -> bool:
	return Player.instance.held_object != null and Player.instance.held_object.name == "Key" or has_key

func on_interact():
	# When clicked with a key held, place it in the socket
	if Player.instance.held_object != null and Player.instance.held_object.name == "Key":
		var key = Player.instance.held_object
		# Remove from player hand
		Player.instance.held_object = null
		key.get_parent().remove_child(key)
		
		# Destroy the key sprite
		key.queue_free()
		
		# Destroy the lock sprite
		get_parent().queue_free()
		
		has_key = true
		
		print("Key and lock destroyed!")
		return
		
	if has_key:
		print("Trying to get key")
		# Find the key
		key_object.is_in_key_socket = false
		key_object.freeze = false
		has_key = false
		
		# Remove from socket and add to camera
		remove_child(key_object)
		Player.instance.get_node("Camera3D").add_child(key_object)
		
		# Now pick it up
		key_object.on_pickup()
		Player.instance.held_object = key_object
		
		
		key_object = null
		return
