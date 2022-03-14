extends Artifact

var effect_system: EffectSystem
var health: Health

func _ready() -> void:
	if backpack:
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		health = backpack.entity.get_component(Health.NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(_dir: int) -> bool:
	assert(health)
	if health.health == health.max_health:
		return false
	effect_system.add_effect(preload("res://effects/pillar/pillar.tscn"), backpack.entity.grid_position, Palette.BLUE_1)
	var amount: int = floor(health.max_health * 0.25 * (level + 1))
	health.deal_damage(-amount)
	self.charge = 0
	return true
