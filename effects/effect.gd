extends Node2D
class_name Effect

export(Palette.Enum) var color := 0 setget set_color
export var amount_scale := 1.0

var lifetime: float

func _ready() -> void:
	z_index = 100
	self.color = color
	lifetime = $CPUParticles2D.lifetime / $CPUParticles2D.speed_scale
	$CPUParticles2D.amount *= amount_scale
	$CPUParticles2D.one_shot = true

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func set_color(c: int) -> void:
	color = c
	modulate = Palette.LIST[color]
