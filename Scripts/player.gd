class_name Player

extends CharacterBody3D

@export var move_speed: float
@export var mouse_sensitivity: float
@export var acceleration: float
@export var deceleration: float
@export var gravity: float
@export var interaction_range: float = 3.5
@export_flags_3d_physics var interaction_mask: int
@export var circleUI: Texture2D
@export var crossUI: Texture2D

var walk_velocity: Vector3
var air_velocity: float
var raycast: RayCast3D
var held_object: Grabbable = null
static var instance: Player
var walk_sample_pos: float = 0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# RAYCAST SETUP 
	raycast = RayCast3D.new()
	$Camera3D.add_child(raycast)
	raycast.target_position = Vector3(0, 0, -interaction_range)
	raycast.enabled = true
	raycast.collision_mask = interaction_mask
	instance = self
	
func _physics_process(_delta: float) -> void:
	velocity = get_walk_velocity(_delta) + Vector3.UP * get_air_velocity(_delta)
	move_and_slide()
	
	$CanvasLayer/TextureRect.texture = crossUI
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and (collider.is_in_group("Interactable") or collider.is_in_group("Item")):
			$CanvasLayer/TextureRect.texture = circleUI
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate(Vector3(0, -1, 0), mouse_sensitivity * event.screen_relative.x)
		$Camera3D.rotate(Vector3(-1, 0, 0), mouse_sensitivity * event.screen_relative.y)
		$Camera3D.rotation_degrees.x = clamp($Camera3D.rotation_degrees.x, -90, 90)
		
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		# Drop held object
		if event.pressed and event.keycode == KEY_Q:
			drop_held_object()
			
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			try_interact()


func try_interact():
	# If already holding something
	if held_object:
		print("Already holding object, will try to place it")
		# Check if hitting an interactable
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			print("Raycast hit: ", collider.name if collider else "nothing")
			if collider and collider.is_in_group("Interactable"):
				# Check if it's not a grabbable 
				if not (collider is Grabbable):
					pick_up_object(collider)
					return
		# If not hitting a socket- drop normally
		print("Dropping gear normally")
		drop_held_object()
		return
		
	# Normal pickup logic when not holding anything
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		print("Raycast hit: ", collider.name if collider else "nothing")
		if collider and collider.is_in_group("Interactable"):
			pick_up_object(collider)
	else:
		print("Raycast not hitting anything")
	
func pick_up_object(object: Node3D):
	
	# Check if it's actually grabbable
	if not (object is Grabbable):
		object.on_pickup()
		return
	
	# For grabbable objects
	if held_object:
		drop_held_object()
		return
		
	var success = object.can_pickup()
	if not success: return
	
	object.on_pickup()
	
	var object_parent = object.get_parent()
	object_parent.remove_child(object)
	# Attach to camera 
	$Camera3D.add_child(object)
	held_object = object
	
func interact_object(object: Node3D):
	if object.can_interact():
		object.on_interact()

func drop_held_object():
	if not held_object:
		return
	
	# Remove from camera
	$Camera3D.remove_child(held_object)
	# Add back to scene
	get_tree().root.get_child(0).add_child(held_object)
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		# Move your object to the collision_point
		held_object.global_transform.origin = collision_point
		held_object.global_transform.origin = held_object.global_transform.origin.move_toward(global_transform.origin, 0.2)
	# Position in front of player
	else:
		held_object.global_transform.origin = $Camera3D.global_transform.origin + $Camera3D.global_transform.basis * Vector3.FORWARD * interaction_range
	held_object.on_dropped()
	held_object = null

func get_walk_velocity(_delta: float):
	walk_velocity = walk_velocity.move_toward(Vector3.ZERO, deceleration * _delta)
	var _input_dir: Vector2 = Input.get_vector("Left", "Right", "Forward", "Backward")
	var _forward: Vector3 = global_transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)
	var _move_dir: Vector3 = _forward.normalized()
	walk_velocity = walk_velocity.move_toward(_move_dir * move_speed * _input_dir.length(), acceleration * _delta)
	if !$WalkingSFX.playing and _input_dir != Vector2.ZERO:
		$WalkingSFX.play(walk_sample_pos)
	if $WalkingSFX.playing and _input_dir == Vector2.ZERO:
		walk_sample_pos = $WalkingSFX.get_playback_position()
		$WalkingSFX.stop()
	return walk_velocity

func get_air_velocity(_delta: float):
	if not is_on_floor():
		air_velocity += gravity * _delta
	return air_velocity

func play_eating_sfx():
	$EatingSFX.play()
