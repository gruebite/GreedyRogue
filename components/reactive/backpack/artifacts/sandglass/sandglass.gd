extends Artifact

var effect_system: EffectSystem
var controller

func _ready() -> void:
	if backpack:
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		controller = backpack.entity.get_component("Controller")

func _on_out_of_turn() -> void:
	self.charge += 1

func use(_dir) -> bool:
	controller.skip_turns = (level + 1) * 2
	self.charge = 0

	effect_system.add_effect(preload("res://effects/spell_cast/spell_cast.tscn"), backpack.entity.grid_position, Palette.ORANGE_2)
	return true
