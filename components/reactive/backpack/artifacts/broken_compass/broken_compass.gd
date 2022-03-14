extends Artifact

var effect_system: EffectSystem
var hoard_system: HoardSystem

func _ready() -> void:
	if backpack:
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		hoard_system = backpack.find_system(HoardSystem.GROUP_NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(_dir: int) -> bool:
	if hoard_system.piles.size() == 0:
		return false
	var closest_dist := 9999
	var closest_gpos := Vector2(9999, 9999)
	var ourpos: Vector2 = backpack.entity.grid_position
	for gold in hoard_system.piles:
		var dv: Vector2 = (gold.entity.grid_position - ourpos).abs()
		var d: int = dv.x + dv.y
		if d < closest_dist:
			closest_dist = d
			closest_gpos = gold.entity.grid_position

	effect_system.add_effect(preload("res://effects/ping/ping.tscn"), closest_gpos, Palette.ORANGE_2)
	self.charge = 0
	return false
