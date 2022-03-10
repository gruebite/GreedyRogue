extends Node2D
class_name Effect

export var above := true
export var lifetime := 0.3

func _ready() -> void:
	if above:
		z_index = 100
	else:
		z_index = -100

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
