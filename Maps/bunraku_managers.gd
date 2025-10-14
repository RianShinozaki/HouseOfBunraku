extends Node3D

enum {YONO, YOROI}
@export var bunraku_active_time: float

var current_active_time: float
var active_bunraku: int
var active_bunraku_ref: Bunraku

func _ready() -> void:
	active_bunraku = YONO
	active_bunraku_ref = $Yono
	active_bunraku_ref.activate()
	
func _process(delta: float) -> void:
	if active_bunraku_ref.anger_level < 0.33:
		current_active_time += delta
	if current_active_time > bunraku_active_time:
		active_bunraku_ref.deactivate()
		if active_bunraku == YONO:
			active_bunraku = YOROI
			active_bunraku_ref = $Yoroi
		else:
			active_bunraku = YONO
			active_bunraku_ref = $Yono
		active_bunraku_ref.activate()
		current_active_time = 0
		$CreakSFX.play()
