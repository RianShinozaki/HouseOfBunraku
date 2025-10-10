extends CharacterBody3D

@export var move_speed: float
@export var mouse_sensitivity: float
@export var acceleration: float
@export var deceleration: float
@export var gravity: float
@export var interaction_range: float = 3.5

var walk_velocity: Vector3
var air_velocity: float
var raycast: RayCast3D
var held_object: Node3D = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# RAYCAST SETUP 
	raycast = RayCast3D.new()
	$Camera3D.add_child(raycast)
	raycast.target_position = Vector3(0, 0, -interaction_range)
	raycast.enabled = true
	
func _physics_process(_delta: float) -> void:
	velocity = get_walk_velocity(_delta) + Vector3.UP * get_air_velocity(_delta)
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate(Vector3(0, -1, 0), mouse_sensitivity * event.screen_relative.x)
		$Camera3D.rotate(Vector3(-1, 0, 0), mouse_sensitivity * event.screen_relative.y)
		$Camera3D.rotation_degrees.x = clamp($Camera3D.rotation_degrees.x, -90, 90)
		
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event.pressed and event.keycode == KEY_E:
			try_interact()
		# Drop held object
		if event.pressed and event.keycode == KEY_Q:
			drop_object()
			
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func try_interact():
	# If already holding something drop it
	if held_object:
		drop_object()
		return
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		# Check if object is pickupable
		if collider and collider.is_in_group("pickupable"):
			pick_up_object(collider)

func pick_up_object(object):
	print("Picked up: ", object.name)
	
	# Remove from current parent
	var object_parent = object.get_parent()
	object_parent.remove_child(object)
	
	# Disable all collisions
	for child in object.get_children():
		if child is CollisionShape3D:
			child.disabled = true
	
	# Attach to camera 
	$Camera3D.add_child(object)
	
	# POSITION IN FRONT OF CAMERA 
	object.position = Vector3(0.3, -0.2, -0.5)  
	object.rotation_degrees = Vector3(0, 0, 0)
	object.scale = Vector3(1, 1, 1) 
	
	held_object = object

func drop_object():
	if not held_object:
		return
	
	print("Dropped: ", held_object.name)
	
	# Remove from camera
	$Camera3D.remove_child(held_object)
	
	# Add back to scene (to the root or Environment)
	get_tree().root.get_child(0).add_child(held_object)
	
	# Position in front of player
	held_object.global_position = global_position + global_transform.basis.z * -1.0
	
	# Re-enable collisions
	for child in held_object.get_children():
		if child is CollisionShape3D:
			child.disabled = false
	
	held_object = null

func get_walk_velocity(_delta: float):
	walk_velocity = walk_velocity.move_toward(Vector3.ZERO, deceleration * _delta)
	var _input_dir: Vector2 = Input.get_vector("Left", "Right", "Forward", "Backward")
	var _forward: Vector3 = global_transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)
	var _move_dir: Vector3 = _forward.normalized()
	walk_velocity = walk_velocity.move_toward(_move_dir * move_speed * _input_dir.length(), acceleration * _delta)
	return walk_velocity

func get_air_velocity(_delta: float):
	if not is_on_floor():
		air_velocity += gravity * _delta
	return air_velocity
