extends OmniLight3D

@export var energy_range: Vector2
@export var energy_change: float
@export var energy_delta_range: float

func _process(_delta: float) -> void:
	energy_change += randf_range(-energy_delta_range, energy_delta_range)
	light_energy += energy_change
	if light_energy < energy_range.x or light_energy > energy_range.y:
		energy_change = 0
	light_energy = clampf(light_energy, energy_range.x, energy_range.y)
