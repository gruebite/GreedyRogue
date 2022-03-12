extends Artifact

var effect_system: EffectSystem
var generator_system: GeneratorSystem

func _ready() -> void:
	if backpack:
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		generator_system = backpack.find_system(GeneratorSystem.GROUP_NAME)

func use(_dir: int) -> bool:
	effect_system.add_effect(
		preload("res://effects/ping/ping.tscn"),
		generator_system.exit_position)
	queue_free()
	return true
