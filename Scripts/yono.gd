@tool

class_name Yono

extends Bunraku

@export var too_close_distance: float
@export var too_close_curve: Curve
@export var too_close_factor: float

@export var look_anger_range: float
@export var look_anger_curve: Curve
@export var look_anger_factor: float



func _ready() -> void:
	super._ready()
	active = true

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): 
		debug_draw(_delta)
		return
	var _vec_to_player = (Player.instance.global_position - (global_position + Vector3.UP * 0.2))
	var _dist_to_player = _vec_to_player.length()
	if _dist_to_player < too_close_distance:
		var _samp = too_close_curve.sample(1-(_dist_to_player/too_close_distance))
		anger_level += _delta * _samp * too_close_factor
		anger_decrease_delta = 0
	var _player_forward = Player.instance.get_node("Camera3D").global_basis * Vector3.FORWARD
	var _angle = _player_forward.angle_to(-_vec_to_player)
	if _angle < look_anger_range:
		var _samp = look_anger_curve.sample(1-(_angle/look_anger_range))
		anger_level += _delta * _samp * look_anger_factor
		anger_decrease_delta = 0
	if get_tree().get_nodes_in_group("Meat").size() > 0:
		anger_level += _delta * 0.08
		anger_decrease_delta = 0
	
	super._physics_process(_delta)
	
func debug_draw(_delta: float) -> void:
	var _a11 = DebugDraw3D.new_scoped_config().set_thickness(0.005)
	DebugDraw3D.draw_sphere(global_position, too_close_distance, Color.RED)
