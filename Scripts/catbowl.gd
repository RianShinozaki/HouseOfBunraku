extends StaticBody3D

@export var meat_ball: PackedScene
var meated: bool = false

func _process(_delta: float) -> void:
	if Player.instance.held_object is Meatball:
		if not is_in_group("Interactable"):
			add_to_group("Interactable")
	else:
		if is_in_group("Interactable") and not meated:
			remove_from_group("Interactable")

func can_interact():
	return (Player.instance.held_object is Meatball and not meated) or (Player.instance.held_object == null and meated)

func on_interact():
	if not meated:
		Player.instance.held_object.queue_free()
		Player.instance.held_object = null
		meated = true
		$"..".frame = 1
		add_to_group("Meat")
	else:
		meated = false
		$"..".frame = 0
		var _meat = meat_ball.instantiate()
		Player.instance.get_node("Camera3D").add_child(_meat)
		Player.instance.held_object = _meat
		_meat.on_pickup()
		$SFX.play()
		remove_from_group("Meat")
