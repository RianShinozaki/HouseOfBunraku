@tool

class_name Yono

extends Bunraku

@export var too_close_distance: float
@export var too_close_curve: Curve
@export var too_close_factor: float

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	var _dist_to_player = (Player.instance.global_position - global_position).length()
	if _dist_to_player < too_close_distance:
		var _samp = too_close_curve.sample(1-(_dist_to_player/too_close_factor))
		anger_level += _delta * _samp * too_close_factor
	super._physics_process(_delta)
