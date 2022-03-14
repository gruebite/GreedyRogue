extends Artifact

var effect_system: EffectSystem
var navigation_system: NavigationSystem

func _ready() -> void:
	if backpack:
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(_dir: int) -> bool:
	effect_system.add_effect(preload("res://effects/spell_cast/spell_cast.tscn"), backpack.entity.grid_position, Palette.VIOLET_0)
	navigation_system.move_to(backpack.entity, navigation_system.find_random_unblocked())
	effect_system.add_effect(preload("res://effects/spell_cast/spell_cast.tscn"), backpack.entity.grid_position, Palette.VIOLET_0)
	self.charge = 0
	return false
