@tool

class_name Yono

extends Bunraku

@export var too_close_distance: float
@export var too_close_curve: Curve
@export var too_close_factor: float

func _ready() -> void:
	super._ready()
	active = true

func _physics_process(_delta: float) -> void:
	debug_draw(_delta)
	if Engine.is_editor_hint(): 
		
		return
	var _dist_to_player = (Player.instance.global_position - global_position).length()
	if _dist_to_player < too_close_distance:
		var _samp = too_close_curve.sample(1-(_dist_to_player/too_close_distance))
		anger_level += _delta * _samp * too_close_factor
		anger_decrease_delta = 0
	super._physics_process(_delta)

func debug_draw(_delta: float) -> void:
	var _a11 = DebugDraw3D.new_scoped_config().set_thickness(0.005)
	DebugDraw3D.draw_sphere(global_position, too_close_distance, Color.RED)
