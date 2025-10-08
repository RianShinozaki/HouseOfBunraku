extends CharacterBody3D

@export var move_speed: float
@export var mouse_sensitivity: float
@export var acceleration: float
@export var deceleration: float
@export var gravity: float

var walk_velocity: Vector3
var air_velocity: float

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
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
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
