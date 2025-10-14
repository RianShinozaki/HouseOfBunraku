class_name Yoroi

extends Bunraku

@export var look_anger_range: float
@export var look_anger_curve: Curve
@export var look_anger_factor: float

@export var no_look_max_time: float

var no_look_time: float = 0

func _ready() -> void:
	super._ready()
	active = true

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): 
		return
	var _vec_to_player = (Player.instance.global_position - (global_position + Vector3.UP * 0.2))
	var _player_forward = Player.instance.get_node("Camera3D").global_basis * Vector3.FORWARD
	var _angle = _player_forward.angle_to(-_vec_to_player)
	if _angle > look_anger_range:
		no_look_time += _delta
		if no_look_time > no_look_max_time:
			var _samp = look_anger_curve.sample(1-(_angle/360))
			anger_level += _delta * _samp * look_anger_factor
			anger_decrease_delta = 0
	else:
		no_look_time = 0
	
	if GearSocket.instance.has_gear:
		anger_level += _delta * 0.08
		anger_decrease_delta = 0
		
	super._physics_process(_delta)
